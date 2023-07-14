import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_main/utils/console.dart';
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
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class _Base {
  final strogeKey = 'maxrockyInApp';
  final WebDirInfo indexDir;
  final InAppWebViewController controller;

  BuildContext get context {
    return navigatorKey.currentState!.context;
  }

  _Base(this.controller, this.indexDir);

  _callH5(BridgeValue detail) {
    console.log(detail.toJson());

    controller.evaluateJavascript(source: '''
      try{
        window.dispatchEvent(new CustomEvent("onJsBridgeCallBack", { detail: ${detail.toJson()} }))
      } catch (err) {
        console.error('flutter call H5 error. ', err)
      }
    ''');
  }

  getStrogeKey(String key) {
    return '$strogeKey-$key';
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

  Future<WebResourceResponse?> loadAssetsFile(String path) async {
    try {
      late final Uint8List data;

      if (indexDir.version == defaultVersion) {
        data = (await rootBundle.load(join(WEB_ASSETS_PATH, path))).buffer.asUint8List();
        final mimeType = lookupMimeType(basename(path));
        return WebResourceResponse(data: data, statusCode: 200, reasonPhrase: 'OK', contentType: mimeType);
      }
      return loadFile(join(indexDir.path, path));
    } catch (e) {
      debugPrint('load file err. path => $path');
    }
    return null;
  }

  Future<WebResourceResponse?> loadFile(String path) async {
    final file = File(path);

    if (!file.existsSync()) return null;

    try {
      final data = await file.readAsBytes();
      final mimeType = lookupMimeType(basename(path));
      return WebResourceResponse(data: data, statusCode: 200, reasonPhrase: 'OK', contentType: mimeType);
    } catch (e) {
      console.error(e);
    }
    return null;
  }

  Future<WebResourceResponse?> analyzingScheme(String path) async {
    // late final MaxRockyMes req;
    if (isWithin(schemeFilePaht, path)) {
      return loadFile(path.replaceFirst(schemeFilePaht, ''));
    }
    return loadAssetsFile(path.replaceFirst('/', ''));
  }

  path2Scheme(String url) {
    return '$schemeBase$schemeFilePaht$url';
  }
}

class Jssdk extends _Base {
  Jssdk(super.controller, super.indexDir);

  /// 来自H5的消息
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
      case MethodName.pickerPhoto:
        data = await pickerPhoto(event);
        break;
      case MethodName.openCamera:
        data = await openCamera(event);
        break;
      case MethodName.navPop:
        data = await navPop(event);
        break;
      default:
        data = BridgeValue(code: 404, sessionId: event.sessionId);
    }

    data.sessionId = event.sessionId;
    _callH5(data);
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
    return BridgeValue(code: 0, data: data);
  }

  /// 存储数据
  setLocalStorage(MaxRockyMes event) async {
    final info = json.decode(event.params ?? '');
    final key = info['key'];
    final value = info['value'];

    if (key == null || value == null) {
      return BridgeValue(code: -1, msg: 'not find key or not find value');
    }

    final prefs = await storage;
    prefs.setString(getStrogeKey(key), value);
    return BridgeValue(code: 0);
  }

  /// 读取数据
  getLocalStorage(MaxRockyMes event) async {
    final key = event.params;

    if (key == null) {
      return BridgeValue(code: -1, msg: 'not find key');
    }

    final prefs = await storage;
    final data = prefs.getString(getStrogeKey(key));
    return BridgeValue(code: 0, data: "'$data'");
  }

  /// 移除数据
  removeLocalStroge(MaxRockyMes event) async {
    final key = event.params;

    if (key == null) {
      return BridgeValue(code: -1, msg: 'not find key');
    }

    final prefs = await storage;
    final data = await prefs.remove(getStrogeKey(key));
    return BridgeValue(code: 0, data: "$data");
  }

  /// 清空数据
  clearLocalStroge(MaxRockyMes event) async {
    final prefs = await storage;

    /// 只清除webview存储的数据
    final List<Future<bool>> waitList = [];
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(strogeKey)) waitList.add(prefs.remove(key));
    }

    await Future.wait(waitList);
    return BridgeValue(code: 0, data: "true");
  }

  /// 扫码
  qrcode(MaxRockyMes event) async {
    final route = MaterialPageRoute(builder: (context) => const QrCodeView());
    final res = await Navigator.of(super.context).push(route);

    return BridgeValue(code: 0, data: "'${res ?? ''}'");
  }

  /// 打开相册读取图片
  pickerPhoto(MaxRockyMes event) async {
    final result = await AssetPicker.pickAssets(super.context, pickerConfig: const AssetPickerConfig());
    final photoInfo = result?.map((AssetEntity i) async {
          var path = (await i.originFile)?.absolute.path;
          if (path != null) path = '"${path2Scheme(path)}"';

          return '''{
            title: "${i.title}",
            width: ${i.width},
            height: ${i.height},
            mimeType: "${i.mimeType}",
            path: $path
          }''';
        }).toList() ??
        [];

    final data = await Future.wait(photoInfo);
    return BridgeValue(code: 0, data: data.toString());
  }

  /// 打开相机
  openCamera(MaxRockyMes event) async {
    final photo = await CameraPicker.pickFromCamera(super.context);

    if (photo == null) return BridgeValue(code: -1, msg: "take photo fail.");

    var path = (await photo.originFile)?.absolute.path;
    if (path != null) path = '"${path2Scheme(path)}"';

    final photoInfo = '''{
      title: "${photo.title}",
      width: ${photo.width},
      height: ${photo.height},
      mimeType: "${photo.mimeType}",
      path: $path
    }''';

    return BridgeValue(code: 0, data: photoInfo);
  }

  /// 返回
  navPop(MaxRockyMes event) async {
    Navigator.of(super.context).pop();

    return BridgeValue(code: 0);
  }
}
