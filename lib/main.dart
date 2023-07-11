import 'package:flutter/material.dart';
import 'package:flutter_main/common/checkUpgrade.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/views/webiew.dart';

// adb connect 192.168.8.100:41599

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();
  checkUpgrade();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaxRocky Jssdk',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Webiew(),
    );
  }
}
