import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() => new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

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
              initialUrlRequest: URLRequest(url: WebUri('https://baidu.com')),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;

                if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    // Launch the App
                    await launchUrl(
                      uri,
                    );
                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                return NavigationActionPolicy.ALLOW;
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
                  urlController.text = this.url;
                });
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              shouldInterceptRequest: (InAppWebViewController controller, WebResourceRequest request) async {
                print(['onLoadResourceCustomScheme', request.url]);
              },
            ),
            progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
          ],
        ),
      ),
    ])));
  }
}
