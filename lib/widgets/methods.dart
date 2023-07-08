import 'package:flutter/material.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Jssdk {
  final WebViewController controller;
  Jssdk(this.controller);

  handler(MaxRockyMes event) {
    switch (event.methodName) {
      case MethodName.deviceInfo:
        getDeviceInfo(event);
        break;
      default:
    }
  }

  callH5(String data, int id) {
    controller.runJavaScript("""
    window.dispatchEvent(new CustomEvent("BridgeCallBack", { detail: { code: 0, sessionId: $id, data: "$data", msg: "success" } }))
""");
  }

  getDeviceInfo(MaxRockyMes event) {
    final top = MediaQuery.of(navigatorKey.currentState!.context).padding.top;

    callH5(top.toString(), event.sessionId);
    // return MediaQuery.of(navigatorKey.currentState!.context).padding.top;
  }
}

// final jssdk = Jssdk();
