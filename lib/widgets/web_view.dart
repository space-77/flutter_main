import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_main/widgets/methods.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Webview extends StatefulWidget {
  String url;
  Webview({Key? key, required this.url}) : super(key: key);

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  late final WebViewController _controller;
  late final jssdk;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    jssdk = Jssdk(controller);
    // #enddocregion platform_features

    // print(['object', controller.setUserAgent('userAgent')]);

    controller
      // ..setUserAgent('maxrocky')
      // ..set
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            // controller.runJavaScript('window.onMaxrockyReady()');
            // controller.runJavaScriptReturningResult('navigator.userAgent').then((Object userAgent) {
            //   controller.setUserAgent("maxrocky");
            //   // print(['runJavaScriptReturningResult', currentUserAgent]);
            // });
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            controller.runJavaScript("""
      try {
        window.onMaxrockyReady();
      } catch (err) {
        console.error(err)
      }
""");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(widget.url)) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )

      // 接收 H5 的通知
      ..addJavaScriptChannel(
        'maxrocky',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final mes = MaxRockyMes.fromJson(json.decode(message.message));
            jssdk.handler(mes);
          } catch (e) {
            print(['序列化H5消息异常', e]);
          }
          // print(['object', mes.methodName]);

          // __maxrockyWebViewJavascriptBridgeCallBack__

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(message.message)),
          // );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
