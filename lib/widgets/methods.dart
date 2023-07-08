import 'package:flutter/material.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/bridgeValue.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Jssdk {
  final WebViewController controller;
  Jssdk(this.controller);

  onMaxrockyReady() {
    controller.runJavaScript('window.dispatchEvent(new CustomEvent("onMaxrockyReady"))');
  }

  handler(MaxRockyMes event) {
    switch (event.methodName) {
      case MethodName.deviceInfo:
        getDeviceInfo(event);
        break;
      default:
    }
  }

  _callH5(BridgeValue detail) {
    controller.runJavaScript('''
    try{
      window.dispatchEvent(new CustomEvent("onBridgeCallBack", { detail: ${detail.toJson()} }))
    } catch (err) {
      console.error('flutter call H5 error. message: ', err)
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
}
