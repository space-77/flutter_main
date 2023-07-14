import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_main/common/checkUpgrade.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/views/dev_webview_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// adb connect 192.168.8.100:41599

Future main() async {
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        /// 这是设置状态栏的图标和字体的颜色
        /// Brightness.light  一般都是显示为白色
        /// Brightness.dark 一般都是显示为黑色
        statusBarIconBrightness: Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();
  final indexDir = await init();

  print(['indexDir.path', indexDir.path]);

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
