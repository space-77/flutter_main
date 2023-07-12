import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_main/utils/device_utils.dart';
import 'package:mime/mime.dart';
import 'package:nb_utils/nb_utils.dart' as nb;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/views/qrCodeView.dart';
import 'package:flutter_main/types/bridgeValue.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Jssdk {
  final strogeKey = 'maxrockyInApp';
  final WebDirInfo indexDir;
  final InAppWebViewController controller;

  Jssdk(this.controller, this.indexDir);

  getStrogeKey(String key) {
    return '$strogeKey-$key';
  }

  onEventListener() {
    controller.addJavaScriptHandler(
      handlerName: 'postMessage',
      callback: (args) {
        try {
          final String? message = args[0];
          if (message == null || message == '') return;
          final event = MaxRockyMes.fromJson(json.decode(message));
          handler(event);
        } catch (e) {
          print(['h5 call flutter error.', e]);
        }
      },
    );
  }

  onMaxrockyReady() {
    controller.evaluateJavascript(source: '''
      try {
        window.dispatchEvent(new CustomEvent("onMaxrockyReady", {detail: { baseScheme: "$schemeBase" }}));
      } catch (err) {
        console.error('webview onready fail. ', err);
      }
    ''');
  }

  handler(MaxRockyMes event) async {
    late BridgeValue data;
    switch (event.methodName) {
      case MethodName.deviceInfo:
        data = await getDeviceInfo(event);
        break;
      case MethodName.getLocalStorage:
        data = await getLocalStorage(event);
        break;
      case MethodName.setLocalStorage:
        data = await setLocalStorage(event);
        break;
      case MethodName.removeLocalStroge:
        data = await removeLocalStroge(event);
        break;
      case MethodName.clearLocalStroge:
        data = await clearLocalStroge(event);
        break;
      case MethodName.qrcode:
        data = await qrcode(event);
        break;
      default:
        data = BridgeValue(code: 404, sessionId: event.sessionId);
    }
    _callH5(data);
  }

  _callH5(BridgeValue detail) {
    print(['detail.toJson()', detail.toJson()]);
    controller.evaluateJavascript(source: '''
      try{
        window.dispatchEvent(new CustomEvent("onJsBridgeCallBack", { detail: ${detail.toJson()} }))
      } catch (err) {
        console.error('flutter call H5 error. ', err)
      }
    ''');
  }

  Future<WebResourceResponse?> loadAssetsFile(String path) async {
    try {
      late final Uint8List data;

      if (indexDir.version == defaultVersion) {
        data = (await rootBundle.load(join(WEB_ASSETS_PATH, path))).buffer.asUint8List();
      } else {
        data = await File(join(indexDir.path, path)).readAsBytes();
      }
      final mimeType = lookupMimeType(basename(path));

      return WebResourceResponse(data: data, statusCode: 200, reasonPhrase: 'OK', contentType: mimeType);
    } catch (e) {
      debugPrint('load file err. path => $path');
      return null;
    }
  }

  Future<WebResourceResponse?> analyzingScheme(String path) async {
    // late final MaxRockyMes req;
    if (isWithin(schemeFilePaht, path)) {
      // apiPaht
      print(['----------', path]);
    }
    return loadAssetsFile(path.replaceFirst('/', ''));
  }

  /// 获取设备状态栏高度，底部黑条高度，屏幕像素密度比
  getDeviceInfo(MaxRockyMes event) {
    final deviceInfo = MediaQuery.of(navigatorKey.currentState!.context);
    final pixelRatio = deviceInfo.devicePixelRatio;
    final statusBarHeight = deviceInfo.padding.top;
    final bottomBarHeight = deviceInfo.padding.bottom;
    final systemName = nb.operatingSystemName;
    final data = '''
      { 
        pixelRatio: $pixelRatio,
        systemName: "$systemName",
        statusBarHeight:$statusBarHeight,
        bottomBarHeight: $bottomBarHeight
      }
    ''';
    return BridgeValue(code: 0, sessionId: event.sessionId, data: data);
  }

  /// 存储数据
  setLocalStorage(MaxRockyMes event) async {
    final info = json.decode(event.params ?? '');
    final key = info['key'];
    final value = info['value'];
    final sessionId = event.sessionId;

    if (key == null || value == null) {
      return BridgeValue(code: -1, sessionId: sessionId, msg: 'not find key or not find value');
    }

    final prefs = await storage;
    prefs.setString(getStrogeKey(key), value);
    return BridgeValue(code: 0, sessionId: sessionId);
  }

  /// 读取数据
  getLocalStorage(MaxRockyMes event) async {
    final key = event.params;
    final sessionId = event.sessionId;

    if (key == null) {
      return BridgeValue(code: -1, sessionId: sessionId, msg: 'not find key');
    }

    final prefs = await storage;
    final data = prefs.getString(getStrogeKey(key));
    return BridgeValue(code: 0, sessionId: sessionId, data: "'$data'");
  }

  /// 移除数据
  removeLocalStroge(MaxRockyMes event) async {
    final key = event.params;
    final sessionId = event.sessionId;

    if (key == null) {
      return BridgeValue(code: -1, sessionId: sessionId, msg: 'not find key');
    }

    final prefs = await storage;
    final data = await prefs.remove(getStrogeKey(key));
    return BridgeValue(code: 0, sessionId: sessionId, data: "$data");
  }

  /// 清空数据
  clearLocalStroge(MaxRockyMes event) async {
    final sessionId = event.sessionId;

    final prefs = await storage;

    /// 只清除webview存储的数据
    final List<Future<bool>> waitList = [];
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(strogeKey)) waitList.add(prefs.remove(key));
    }

    await Future.wait(waitList);
    return BridgeValue(code: 0, sessionId: sessionId, data: "true");
  }

  /// 扫码
  qrcode(MaxRockyMes event) async {
    final sessionId = event.sessionId;

    final res = await Navigator.of(navigatorKey.currentState!.context).push(
      MaterialPageRoute(
        builder: (context) => const QrCodeView(),
      ),
    );

    return BridgeValue(code: 0, sessionId: sessionId, data: "'${res ?? ''}'");
  }
}
