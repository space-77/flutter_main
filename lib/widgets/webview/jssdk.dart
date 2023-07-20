import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_main/common/notification.dart';
import 'package:flutter_main/services/client.dart';
import 'package:flutter_main/utils/console.dart';
import 'package:flutter_main/utils/dir_path.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class _Base {
  final strogeKey = 'maxrockyInApp';
  final WebDirInfo indexDir;
  final InAppWebViewController controller;
  final localNotifications = FlutterLocalNotificationsPlugin();

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

  Future<WebResourceResponse?> loadFile4Url(WebUri url) async {
    final query = LoadFile.fromJson(url.queryParameters);
    final id = query.id;
    final filePath = query.path;

    if (id != null) {
      final asset = await AssetEntity.fromId(id);
      if (asset == null) return null;

      final data = await (await asset.file)?.readAsBytes();
      return WebResourceResponse(data: data, statusCode: 200, reasonPhrase: 'OK', contentType: asset.mimeType);
    } else if (filePath != null) {
      return await loadAssetsFile(filePath);
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

  Future<WebResourceResponse?> analyzingScheme(WebUri url) async {
    final path = url.path;
    if (assetsPaht == path) return await loadFile4Url(url);
    return await loadAssetsFile(path.replaceFirst('/', ''));
  }

  path2AssetScheme({String? id, String? path}) {
    final idStr = id != null ? 'id=$id' : '';
    var pathStr = path != null ? 'path=$path' : '';
    if (pathStr != '') pathStr = idStr != '' ? '&$pathStr' : pathStr;

    return '$schemeBase$assetsPaht?$idStr$pathStr';
  }

  localNotificationCallH5(NotificationResponseType type, String? payload) {
    final t =
        type == NotificationResponseType.selectedNotification ? 'selectedNotification' : 'selectedNotificationAction';
    final params = {'type': t, 'payload': payload};
    controller.evaluateJavascript(source: '''
      try {
        if (window.flutter_inappwebview && typeof window.flutter_inappwebview.onDidReceiveNotificationResponse === 'function' ) {
          window.flutter_inappwebview.onDidReceiveNotificationResponse(${json.encode(params)});
        }
      } catch (e) {
        console.error(e)
      }
    ''');
  }

  Map<String, dynamic> _passParams(String? params) {
    if (params == '' || params == null) params = '{}';
    return json.decode(params);
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
        case MethodName.httpRequest:
          data = await httpRequest(event);
          break;
        case MethodName.localNotification:
          data = await localNotification(event.params);
          break;
        case MethodName.upload:
          data = await upload(event);
          break;
        case MethodName.fileDownload:
          data = await fileDownload(event);
          break;
        default:
          data = BridgeValue(code: 404, sessionId: event.sessionId, msg: "'404. not find api: ${event.api}'");
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
    final info = SetLocalStorage.fromJson(_passParams(event.params));
    final key = info.key;
    final value = info.value;

    if (key == null || value == null) return BridgeValue(code: -1, msg: 'not find key or not find value');

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
    try {
      final photoParams = PhotoParams.fromJson(_passParams(event.params));
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
              path: "${path2AssetScheme(id: i.id)}"
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
    final cameraParams = CameraParams.fromJson(_passParams(event.params));
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
      path: "${path2AssetScheme(id: photo.id)}"
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
    final tosatParams = ToastParams.fromJson(_passParams(event.params));

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

  /// 网络请求
  Future<BridgeValue> httpRequest(WebviewMsg event) async {
    final config = HttpRequestConfig.fromJson(_passParams(event.params));
    final res = await request(config);
    final data = {'data': res.data, 'status': res.statusCode};

    return BridgeValue(code: 0, data: '`${json.encode(data)}`');
  }

  /// 本地通知
  Future<BridgeValue> localNotification(String? param, [int? id]) async {
    final params = LocalNotificationParams.fromJson(_passParams(param));
    await notification.send(params, localNotificationCallH5, id: id);
    return BridgeValue(code: 0);
  }

  /// 文件上传
  Future<BridgeValue> upload(WebviewMsg event) async {
    // final dirPath = join(await temporaryDirPath(), 'file');
    // final fileName = basename(fileUrl);
    // final params = LocalNotificationParams.fromJson(_passParams(event.params));
    // await notification.send(params, localNotificationCallH5);

    return BridgeValue(code: 0);
  }

  /// 文件下载
  Future<BridgeValue> fileDownload(WebviewMsg event) async {
    final config = HttpRequestConfig.fromJson(_passParams(event.params));
    final fileUrl = config.url;
    if (fileUrl.validateURL()) {
      final dirPath = join(await temporaryDirPath(), 'file');
      final fileName = basename(fileUrl);
      try {
        // TODO 通知提醒
        final savePath = join(dirPath, fileName);
        final id = DateTime.now().millisecondsSinceEpoch >> 10;
        dio.download(
          fileUrl,
          savePath,
          data: config.data,
          options: getOptions(config),
          queryParameters: config.params,
          onReceiveProgress: (int count, int total) {
            final prs = ((count / total) * 100).toInt();
            final payload = json.encode({
              'savePath': savePath,
              'localUrl': prs < 100 ? 'null' : '${path2AssetScheme(path: savePath)}',
              'status': prs < 100 ? 'downloading' : 'done',
            });

            final notif = '''{
              "title": "文件下载中...",
              "body": "$fileName: 下载进度$prs%", 
              "payload": "$payload"
            }''';

            localNotification(notif, id);
          },
        );
        return BridgeValue(code: 0);
      } catch (e) {
        return BridgeValue(code: 500, msg: "'File download failed.'", error: '`${e.toString()}`');
      }
    } else {
      return BridgeValue(code: 400, msg: "'The URL does not exist or is not standardized.'");
    }
  }
}
