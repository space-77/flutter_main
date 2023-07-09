import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/bridgeValue.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_main/views/qrCodeView.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Jssdk {
  final strogeKey = 'maxrockyH5';
  final WebViewController controller;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Jssdk(this.controller);

  getStrogeKey(String key) {
    return '$strogeKey-$key';
  }

  onMaxrockyReady() {
    controller.runJavaScript('''
      try {
        window.dispatchEvent(new CustomEvent("onMaxrockyReady"));
      } catch (err) {
        console.error('webview onready fail. ', err);
      }
    ''');
  }

  handler(MaxRockyMes event) {
    switch (event.methodName) {
      case MethodName.deviceInfo:
        getDeviceInfo(event);
        break;
      case MethodName.getLocalStorage:
        getLocalStorage(event);
        break;
      case MethodName.setLocalStorage:
        setLocalStorage(event);
        break;
      case MethodName.removeLocalStroge:
        removeLocalStroge(event);
        break;
      case MethodName.clearLocalStroge:
        clearLocalStroge(event);
        break;
      case MethodName.qrcode:
        qrcode(event);
        break;
      default:
    }
  }

  _callH5(BridgeValue detail) {
    print(['detail.toJson()', detail.toJson()]);
    controller.runJavaScript('''
      try{
        window.dispatchEvent(new CustomEvent("onBridgeCallBack", { detail: ${detail.toJson()} }))
      } catch (err) {
        console.error('flutter call H5 error. ', err)
      }
    ''');
  }

  /// 获取设备状态栏高度，底部黑条高度，屏幕像素密度比
  getDeviceInfo(MaxRockyMes event) {
    final deviceInfo = MediaQuery.of(navigatorKey.currentState!.context);
    final pixelRatio = deviceInfo.devicePixelRatio;
    final statusBarHeight = deviceInfo.padding.top;
    final bottomBarHeight = deviceInfo.padding.bottom;
    final data = '{ pixelRatio: $pixelRatio, statusBarHeight:$statusBarHeight, bottomBarHeight: $bottomBarHeight }';
    _callH5(BridgeValue(code: 0, sessionId: event.sessionId, data: data));
  }

  /// 存储数据
  setLocalStorage(MaxRockyMes event) async {
    final info = json.decode(event.params ?? '');
    final key = info['key'];
    final value = info['value'];
    final sessionId = event.sessionId;

    if (key == null || value == null) {
      _callH5(BridgeValue(code: -1, sessionId: sessionId, msg: 'not find key or not find value'));
    }

    final SharedPreferences prefs = await _prefs;
    prefs.setString(getStrogeKey(key), value);
    _callH5(BridgeValue(code: 0, sessionId: sessionId));
  }

  /// 读取数据
  getLocalStorage(MaxRockyMes event) async {
    final key = event.params;
    final sessionId = event.sessionId;

    if (key == null) {
      _callH5(BridgeValue(code: -1, sessionId: sessionId, msg: 'not find key'));
    }

    final SharedPreferences prefs = await _prefs;
    final data = prefs.getString(getStrogeKey(key!));
    _callH5(BridgeValue(code: 0, sessionId: sessionId, data: "'$data'"));
  }

  /// 移除数据
  removeLocalStroge(MaxRockyMes event) async {
    final key = event.params;
    final sessionId = event.sessionId;

    if (key == null) {
      _callH5(BridgeValue(code: -1, sessionId: sessionId, msg: 'not find key'));
    }

    final SharedPreferences prefs = await _prefs;
    final data = await prefs.remove(getStrogeKey(key!));
    _callH5(BridgeValue(code: 0, sessionId: sessionId, data: "$data"));
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
    _callH5(BridgeValue(code: 0, sessionId: sessionId, data: "true"));
  }

  qrcode(MaxRockyMes event) async {
    final sessionId = event.sessionId;

    final res = await Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
      builder: (context) => const QrCodeView(),
    ));

    _callH5(BridgeValue(code: 0, sessionId: sessionId, data: "'${res ?? ''}'"));
  }
}
