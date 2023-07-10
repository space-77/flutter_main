import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_main/packages/local_assets_server.dart';
import 'package:flutter_main/widgets/web_view.dart';
// import 'package:local_assets_server/local_assets_server.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  String url = "http://192.168.70.100:5173/";

  late int time;

  int? port;
  bool isListening = false;
  String? address;

  @override
  initState() {
    time = DateTime.now().millisecondsSinceEpoch;
    _initServer();
    super.initState();
  }

  _initServer() async {
    final server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/www',
      logger: const DebugLogger(),
    );

    final address = await server.serve();
    setState(() {
      this.address = address.address;
      port = server.boundPort!;
      isListening = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isListening ? Webview(url: 'http://$address:$port/') : const Center(child: CircularProgressIndicator()),
    );
  }
}
