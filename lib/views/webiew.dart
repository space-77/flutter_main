import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/widgets/jssdk.dart';

class Webiew extends StatefulWidget {
  final WebDirInfo indexDir;
  const Webiew(this.indexDir, {Key? key}) : super(key: key);

  @override
  _WebiewState createState() => _WebiewState();
}

class _WebiewState extends State<Webiew> {
  final GlobalKey webViewKey = GlobalKey();

  late final Jssdk jssdk;

  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  var loadDone = false;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController?.getUrl(),
                  ),
                );
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
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      TextField(
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
        controller: urlController,
        keyboardType: TextInputType.text,
        onSubmitted: (value) {
          var url = WebUri(value);
          if (url.scheme.isEmpty) {
            url = WebUri('https://www.bing.com/search?q=$value');
          }
          webViewController?.loadUrl(urlRequest: URLRequest(url: url));
        },
      ),
      Expanded(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                widget.indexDir.version.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri("http://192.168.70.100:8080")),
              // initialUrlRequest: URLRequest(url: WebUri(schemeUrl)),
              initialSettings: InAppWebViewSettings(
                minimumFontSize: 0, // 设置webview最小字体
                applicationNameForUserAgent: 'maxrockyWebView',
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
                jssdk = Jssdk(controller, widget.indexDir);
                jssdk.onEventListener();
              },
              onLoadStart: (controller, url) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();

                  // 修复 多次触发 Ready 方法 问题
                  if (!loadDone && progress == 100) jssdk.onMaxrockyReady();
                }
                setState(() {
                  loadDone = progress >= 100;
                  this.progress = progress / 100;
                  urlController.text = url;
                });
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              shouldInterceptRequest: (InAppWebViewController controller, WebResourceRequest request) async {
                final reqUrl = WebUri('${request.url}');
                final origin = '${reqUrl.scheme}://${reqUrl.host}';
                if (origin == schemeBase) return jssdk.analyzingScheme(reqUrl.path);
                return null;
              },
            ),
            progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
          ],
        ),
      ),
    ])));
  }
}
