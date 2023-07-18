import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_main/utils/console.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:nb_utils/nb_utils.dart' as nb;
import 'package:network_info_plus/network_info_plus.dart';
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

  Future<WebResourceResponse?> loadFile4Id(String id) async {
    final asset = await AssetEntity.fromId(id);
    if (asset == null) return null;

    final data = await (await asset.file)?.readAsBytes();
    return WebResourceResponse(data: data, statusCode: 200, reasonPhrase: 'OK', contentType: asset.mimeType);
    // try {
    // } catch (e) {
    //   console.error(e);
    // }
    // return null;
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
    // late final WebviewMsg req;
    if (isWithin(assetsPaht, path)) {
      // return loadFile(path.replaceFirst(schemeFilePaht, ''));
      return loadFile4Id(path.replaceFirst('$assetsPaht/', ''));
    }
    return loadAssetsFile(path.replaceFirst('/', ''));
  }

  path2AssetScheme(String url) {
    return '$schemeBase$assetsPaht$url';
  }
}

class Jssdk extends _Base {
  Jssdk(super.controller, super.indexDir);

  /// 来自H5的消息
  handler(WebviewMsg event) async {
    late BridgeValue data;
    try {
      switch (event.methodName) {
        case MethodName.reload:
          data = onWebviewReLoad(event);
          break;
        case MethodName.deviceInfo:
          data = getDeviceInfo(event);
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
          data = navPop(event);
          break;
        case MethodName.toast:
          data = toast(event);
          break;
        case MethodName.networkInfo:
          data = await getNetworkInfo(event);
          break;
        case MethodName.connectivity:
          data = await getConnectivityInfo(event);
          break;
        case MethodName.setNavigationBarColor:
          data = setNavigationBarColor(event);
          break;
        default:
          data = BridgeValue(code: 404, sessionId: event.sessionId, msg: "'404. not find'");
      }
    } catch (e) {
      console.error(e);
      data = BridgeValue(
        code: 500,
        sessionId: event.sessionId,
        error: "`${e.toString()}`",
        msg: "'Handling information exceptions.'",
      );
    }

    data.api = "'${event.api}'";
    data.sessionId = event.sessionId;
    _callH5(data);
  }

  BridgeValue onWebviewReLoad(WebviewMsg event) {
    controller.reload();
    return BridgeValue(code: 0);
  }

  /// 获取设备状态栏高度，底部黑条高度，屏幕像素密度比
  BridgeValue getDeviceInfo(WebviewMsg event) {
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
  Future<BridgeValue> setLocalStorage(WebviewMsg event) async {
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
  Future<BridgeValue> getLocalStorage(WebviewMsg event) async {
    final key = event.params;

    if (key == null) {
      return BridgeValue(code: -1, msg: 'not find key');
    }

    final prefs = await storage;
    final data = prefs.getString(getStrogeKey(key));
    return BridgeValue(code: 0, data: "'$data'");
  }

  /// 移除数据
  Future<BridgeValue> removeLocalStroge(WebviewMsg event) async {
    final key = event.params;

    if (key == null) {
      return BridgeValue(code: -1, msg: 'not find key');
    }

    final prefs = await storage;
    final data = await prefs.remove(getStrogeKey(key));
    return BridgeValue(code: 0, data: "$data");
  }

  /// 清空数据
  Future<BridgeValue> clearLocalStroge(WebviewMsg event) async {
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
  Future<BridgeValue> qrcode(WebviewMsg event) async {
    final route = MaterialPageRoute(builder: (context) => const QrCodeView());
    final res = await Navigator.of(super.context).push(route);

    return BridgeValue(code: 0, data: "'${res ?? ''}'");
  }

  /// 打开相册读取图片
  Future<BridgeValue> pickerPhoto(WebviewMsg event) async {
    var params = event.params;
    if (params == '' || params == null) params = '{}';
    try {
      final photoParams = PhotoParams.fromJson(json.decode(params));
      final ids = photoParams.selectedAssetIds;
      final maxAssets = photoParams.maxAssets ?? 9;
      final themeColor = photoParams.themeColor;
      final requestType = photoParams.type;

      final selectedAssetsF = ids?.map((id) => AssetEntity.fromId(id)) ?? [];
      final selectedAssets = (await Future.wait(selectedAssetsF)).whereType<AssetEntity>().toList();
      SpecialPickerType? specialPickerType = maxAssets == 1 ? SpecialPickerType.noPreview : null;

      final pickerConfig = AssetPickerConfig(
        maxAssets: maxAssets,
        themeColor: themeColor,
        requestType: requestType,
        selectedAssets: selectedAssets,
        keepScrollOffset: true,
        specialPickerType: specialPickerType,
      );

      final result = await AssetPicker.pickAssets(super.context, pickerConfig: pickerConfig);
      final data = result?.map((AssetEntity i) {
            return '''{
              id: "${i.id}",
              title: "${i.title}",
              width: ${i.width},
              height: ${i.height},
              mimeType: "${i.mimeType}",
              path: "${path2AssetScheme('/${i.id}')}"
            }''';
          }).toList() ??
          [];

      return BridgeValue(code: 0, data: data.toString());
    } catch (e) {
      return BridgeValue(code: 500, data: e.toString());
    }
  }

  /// 打开相机
  Future<BridgeValue> openCamera(WebviewMsg event) async {
    var params = event.params;
    if (params == '' || params == null) params = '{}';

    final cameraParams = CameraParams.fromJson(json.decode(params));
    final enableAudio = cameraParams.enableAudio;
    final enableRecording = cameraParams.enableRecording;
    final enableTapRecording = cameraParams.enableTapRecording;
    final onlyEnableRecording = cameraParams.onlyEnableRecording;
    final minimumRecordingDuration = cameraParams.minimumRecordingDuration;
    final maximumRecordingDuration = cameraParams.maximumRecordingDuration;

    final pickerConfig = CameraPickerConfig(
      enableAudio: enableAudio,
      enableRecording: enableRecording,
      enableTapRecording: enableTapRecording,
      onlyEnableRecording: onlyEnableRecording,
      minimumRecordingDuration: minimumRecordingDuration,
      maximumRecordingDuration: maximumRecordingDuration,
    );

    final photo = await CameraPicker.pickFromCamera(super.context, pickerConfig: pickerConfig);

    if (photo == null) return BridgeValue(code: -1, msg: "take photo fail.");

    final photoInfo = '''{
      id: "${photo.id}",
      title: "${photo.title}",
      width: ${photo.width},
      height: ${photo.height},
      mimeType: "${photo.mimeType}",
      path: "${path2AssetScheme('/${photo.id}')}"
    }''';

    return BridgeValue(code: 0, data: photoInfo);
  }

  /// 返回
  BridgeValue navPop(WebviewMsg event) {
    Navigator.of(super.context).pop();
    return BridgeValue(code: 0);
  }

  /// toast
  BridgeValue toast(WebviewMsg event) {
    var params = event.params;
    if (params == '' || params == null) params = '{}';
    final tosatParams = ToastParams.fromJson(json.decode(params));

    Fluttertoast.showToast(
      msg: tosatParams.msg,
      gravity: tosatParams.position,
      fontSize: tosatParams.fontSize,
      textColor: tosatParams.textColor,
      backgroundColor: tosatParams.backgroundColor,
    );

    return BridgeValue(code: 0);
  }

  /// 获取网络信息
  Future<BridgeValue> getNetworkInfo(WebviewMsg event) async {
    final info = NetworkInfo();
    NetworkItem(info.getWifiIP(), 'IP');
    final getList = [
      NetworkItem(info.getWifiIP(), 'IP'),
      NetworkItem(info.getWifiIPv6(), 'IPv6'),
      NetworkItem(info.getWifiName(), 'name'),
      NetworkItem(info.getWifiBSSID(), 'BSSID'),
      NetworkItem(info.getWifiSubmask(), 'submask'),
      NetworkItem(info.getWifiBroadcast(), 'broadcast'),
      NetworkItem(info.getWifiGatewayIP(), 'gatewayIP'),
    ];

    var data = '{';

    final res = getList.map((item) async {
      try {
        final val = await item.api;
        data += '${item.name}: "$val",';
      } catch (e) {
        data += '${item.name}: undefined,';
      }
    });
    await Future.wait(res);
    data += '}';

    return BridgeValue(code: 0, data: data);
  }

  /// 获取网络链接情况
  Future<BridgeValue> getConnectivityInfo(WebviewMsg event) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    late final String data;

    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        data = 'mobile';
        break;
      case ConnectivityResult.wifi:
        data = 'wifi';
        break;
      case ConnectivityResult.ethernet:
        data = 'ethernet';
        break;
      case ConnectivityResult.vpn:
        data = 'vpn';
        break;
      case ConnectivityResult.bluetooth:
        data = 'bluetooth';
        break;
      case ConnectivityResult.other:
        data = 'other';
        break;
      case ConnectivityResult.none:
      default:
        data = 'none';
    }

    return BridgeValue(code: 0, data: "'$data'");
  }

  /// 设置状态栏文字颜色
  BridgeValue setNavigationBarColor(WebviewMsg event) {
    final type = event.params;
    final err = BridgeValue(code: 500, msg: "'The parameter can only be dark or light.'");

    if (type == 'dark' || type == 'light') {
      late final SystemUiOverlayStyle color;
      switch (type) {
        case 'dark':
          color = SystemUiOverlayStyle.dark;
        case 'light':
          color = SystemUiOverlayStyle.light;
          break;
        default:
          return err;
      }
      SystemChrome.setSystemUIOverlayStyle(color);
      return BridgeValue(code: 0);
    } else {
      return err;
    }
  }
}
