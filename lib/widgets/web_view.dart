import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_main/widgets/jssdk.dart';
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
  late final Jssdk jssdk;

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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            jssdk.onMaxrockyReady();
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
        ),
      )

      // 接收 H5 的通知
      ..addJavaScriptChannel(
        'maxrockyJsbridge',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final msg = MaxRockyMes.fromJson(json.decode(message.message));
            if (msg.methodName == MethodName.reLoad) {
              controller.loadRequest(Uri.parse(widget.url));
            } else {
              jssdk.handler(msg);
            }
          } catch (e) {
            print(['序列化H5消息异常', e]);
          }
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
