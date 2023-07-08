import 'package:flutter/material.dart';
import 'package:flutter_main/widgets/web_view.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  String url = "http://192.168.70.100:5173/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Webview(url: url),
    );
  }
}
