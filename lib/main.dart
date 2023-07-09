import 'package:flutter/material.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/views/web_page.dart';

// adb connect 192.168.8.100:41599
// 可能有用的插件
// appscheme

void main() {
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
      home: const WebPage(),
    );
  }
}
