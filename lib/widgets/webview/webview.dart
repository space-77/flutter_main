import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_main/utils/console.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/widgets/webview/jssdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Webview extends StatefulWidget {
  final WebDirInfo indexDir;
  final void Function(String url)? onUrlChanged;
  const Webview(this.indexDir, {Key? key, this.onUrlChanged}) : super(key: key);

  @override
  WebviewState createState() => WebviewState();
}

class WebviewState extends State<Webview> {
  final GlobalKey webViewKey = GlobalKey();

  late final Jssdk jssdk;
  late final InAppWebViewController webViewController;

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  var loadDone = false;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));
              }
            },
          );
  }

  onEventListener() {
    webViewController.addJavaScriptHandler(
      handlerName: 'postMessage',
      callback: (args) {
        try {
          final String? message = args[0];
          if (message == null || message == '') return;
          final event = WebviewMsg.fromJson(json.decode(message));
          jssdk.handler(event);
        } catch (e) {
          console.error(e);
        }
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'upload',
      callback: (args) {
        try {
          // final String? message = args[0];
          console.log(args);
          // if (message == null || message == '') return;
          // final event = WebviewMsg.fromJson(json.decode(message));
          // jssdk.handler(event);
        } catch (e) {
          console.error(e);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final res = await webViewController.callAsyncJavaScript(functionBody: '''
          if (window.flutter_inappwebview && typeof window.flutter_inappwebview.onWillPop === 'function' ) {
            return window.flutter_inappwebview.onWillPop();
          }
          return true;
        ''');

        return res?.value ?? true;
      },
      child: InAppWebView(
          key: webViewKey,
          // initialUrlRequest: URLRequest(url: WebUri("http://192.168.222.19:8080")),
          initialUrlRequest: URLRequest(url: WebUri(schemeUrl)),
          initialSettings: InAppWebViewSettings(
            disableHorizontalScroll: true,
            useShouldInterceptRequest: true,
            horizontalScrollBarEnabled: false,

            resourceCustomSchemes: [scheme],
            // useShouldOverrideUrlLoading: true,

            minimumFontSize: 0, // 设置webview最小字体
            applicationNameForUserAgent: 'maxrockyWebView',
          ),
          initialUserScripts: UnmodifiableListView<UserScript>([]),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            webViewController = controller;
            jssdk = Jssdk(controller, widget.indexDir);
            onEventListener();
          },
          onLoadStart: (controller, url) {
            if (widget.onUrlChanged != null) widget.onUrlChanged!(url.toString());
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController?.endRefreshing();
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController?.endRefreshing();
              // 修复 多次触发 Ready 方法 问题
              if (!loadDone && progress == 100) jssdk.onMaxrockyReady();
            }

            setState(() {
              loadDone = progress >= 100;
            });
          },

          // 拦截 webview fetch 请求
          shouldInterceptFetchRequest: (controller, fetchRequest) async {
            try {
              if (fetchRequest.body is List) {
                final List<int> body = fetchRequest.body.cast<int>();
                final file = File.fromRawPath(Uint8List.fromList(body));
                console.log(file);
              }
            } catch (e) {
              console.error(e);
            }
            return null;
          },

          /// 安卓资源请求拦截
          shouldInterceptRequest: (controller, request) async {
            final reqUrl = WebUri('${request.url}');
            final origin = '${reqUrl.scheme}://${reqUrl.host}';
            if (origin == schemeBase) return jssdk.analyzingScheme(reqUrl);
            return null;
          },

          /// iOS Scheme
          onLoadResourceWithCustomScheme: (controller, request) async {
            final reqUrl = WebUri('${request.url}');
            final origin = '${reqUrl.scheme}://${reqUrl.host}';

            console.log(origin == schemeBase);

            if (origin == schemeBase) {
              // TODO 返回对应资源 CustomSchemeResponse
              // return jssdk.analyzingScheme(reqUrl);
            }
            return null;
          }),
    );
  }
}
