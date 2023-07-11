import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/bridgeValue.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_main/views/qrCodeView.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Jssdk {
  final strogeKey = 'maxrockyInApp';
  final InAppWebViewController controller;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Jssdk(this.controller);

  getStrogeKey(String key) {
    return '$strogeKey-$key';
  }

  onMaxrockyReady() {
    controller.evaluateJavascript(source: '''
      try {
        window.dispatchEvent(new CustomEvent("onMaxrockyReady"));
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
        window.dispatchEvent(new CustomEvent("onBridgeCallBack", { detail: ${detail.toJson()} }))
      } catch (err) {
        console.error('flutter call H5 error. ', err)
      }
    ''');
  }

  Future<WebResourceResponse?> loadAssetsFile(String path) async {
    try {
      print(['load path', path]);
      ByteData data = await rootBundle.load(path.replaceFirst('/', ''));
      final resData = data.buffer.asUint8List();
      final mimeType = lookupMimeType(basename(path));

      return WebResourceResponse(data: resData, statusCode: 200, reasonPhrase: 'OK', contentType: mimeType);
    } catch (e) {
      debugPrint('load file err. path => $path');
      return null;
    }
  }

  Future<WebResourceResponse?> analyzingScheme(String path) async {
    // late final MaxRockyMes req;
    if (isWithin(WEB_ASSETS_PATH, path)) {
      return loadAssetsFile(path);
    }
    return null;
  }

  /// 获取设备状态栏高度，底部黑条高度，屏幕像素密度比
  getDeviceInfo(MaxRockyMes event) {
    final deviceInfo = MediaQuery.of(navigatorKey.currentState!.context);
    final pixelRatio = deviceInfo.devicePixelRatio;
    final statusBarHeight = deviceInfo.padding.top;
    final bottomBarHeight = deviceInfo.padding.bottom;
    final data = '{ pixelRatio: $pixelRatio, statusBarHeight:$statusBarHeight, bottomBarHeight: $bottomBarHeight }';
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

    final SharedPreferences prefs = await _prefs;
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

    final SharedPreferences prefs = await _prefs;
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

    final SharedPreferences prefs = await _prefs;
    final data = await prefs.remove(getStrogeKey(key));
    return BridgeValue(code: 0, sessionId: sessionId, data: "$data");
  }

  /// 清空数据
  clearLocalStroge(MaxRockyMes event) async {
    final sessionId = event.sessionId;

    final SharedPreferences prefs = await _prefs;

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
