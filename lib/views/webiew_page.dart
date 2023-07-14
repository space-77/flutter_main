import 'package:flutter/material.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/widgets/webview/webview.dart';

class WebiewPage extends StatefulWidget {
  final WebDirInfo indexDir;
  const WebiewPage(this.indexDir, {Key? key}) : super(key: key);

  @override
  _WebiewPageState createState() => _WebiewPageState();
}

class _WebiewPageState extends State<WebiewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Webview(widget.indexDir));
  }
}
