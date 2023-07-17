import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/widgets/webview/webview.dart';

GlobalKey<WebviewState> webviewKey = GlobalKey();

class DevWebiewPage extends StatefulWidget {
  final WebDirInfo indexDir;
  const DevWebiewPage(this.indexDir, {Key? key}) : super(key: key);

  @override
  _DevWebiewPageState createState() => _DevWebiewPageState();
}

class _DevWebiewPageState extends State<DevWebiewPage> {
  final urlController = TextEditingController();

  onUrlChanged(String url) {
    urlController.text = url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: urlController,
              keyboardType: TextInputType.text,
              onSubmitted: (value) {
                var url = WebUri(value);
                if (url.scheme.isEmpty) url = WebUri('https://www.bing.com/search?q=$value');
                webviewKey.currentState?.webViewController.loadUrl(urlRequest: URLRequest(url: url));
              },
            ),
            Expanded(child: Webview(widget.indexDir, onUrlChanged: onUrlChanged, key: webviewKey)),
          ],
        ),
      ),
    );
  }
}
