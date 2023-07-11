import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/widgets/jssdk.dart';

class Webiew extends StatefulWidget {
  const Webiew({Key? key}) : super(key: key);

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
            InAppWebView(
              key: webViewKey,
              // maxrocky://apis.
              initialUrlRequest: URLRequest(url: WebUri("$scheme/assets/www/index.html")),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
                jssdk = Jssdk(controller);
                jssdk.onMaxrockyReady();
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
                }
                setState(() {
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
                if (origin == scheme) return jssdk.analyzingScheme(reqUrl.path);
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
