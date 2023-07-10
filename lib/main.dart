import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/packages/in_app_webiew_example.screen.dart';
import 'package:flutter_main/views/inapp_webview.dart';

// adb connect 192.168.8.100:41599
// 可能有用的插件
// appscheme

// InAppLocalhostServer localhostServer = InAppLocalhostServer(documentRoot: 'assets/www');

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();

  // if (!kIsWeb) {
  //   await localhostServer.start();
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: InAppWebViewExampleScreen(),
    );
  }
}
