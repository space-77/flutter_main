import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_main/common/checkUpgrade.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/views/dev_webview_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// adb pair 192.168.10.52:42225
// adb connect 192.168.8.100:41599

Future main() async {
  late final SystemUiOverlayStyle style;
  if (Platform.isAndroid) {
    style = const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark);
  } else {
    style = SystemUiOverlayStyle.dark;
  }

  // 设置状态栏文字颜色
  SystemChrome.setSystemUIOverlayStyle(style);

  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();
  final indexDir = await init();
  runApp(MyApp(indexDir));
  AssetPicker.registerObserve();
  PhotoManager.setLog(true);
}

class MyApp extends StatelessWidget {
  final WebDirInfo indexDir;
  const MyApp(this.indexDir, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaxRocky Jssdk',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DevWebiewPage(indexDir),
      // home: PickImages(),
    );
  }
}
