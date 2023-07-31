import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_main/utils/color_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum MethodName {
  toast('toast'),
  reload('reload'),
  navPop('navPop'),
  qrcode('qrcode'),
  assets('assets'),
  fileUpload('fileUpload'),
  deviceInfo('deviceInfo'),
  openCamera('openCamera'),
  httpRequest('httpRequest'),
  pickerPhoto('pickerPhoto'),
  networkInfo('networkInfo'),
  fileDownload('fileDownload'),
  connectivity('connectivity'),
  getClipboard('getClipboard'),
  setClipboard('setClipboard'),
  setLocalStorage('setLocalStorage'),
  getLocalStorage('getLocalStorage'),
  clearLocalStroge('clearLocalStroge'),
  localNotification('localNotification'),
  removeLocalStroge('removeLocalStroge'),
  setNavigationBarColor('setNavigationBarColor');

  final String name;
  const MethodName(this.name);
}

class WebviewMsg {
  late int sessionId;
  String? api;
  String? params;
  MethodName? methodName;

  WebviewMsg({required this.sessionId, this.methodName, this.params, this.api});

  WebviewMsg.fromJson(Map<String, dynamic> json) {
    api = json['methodName'];
    params = json['params'];
    sessionId = json['sessionId'];

    switch (json['methodName']) {
      case 'setLocalStorage':
        methodName = MethodName.setLocalStorage;
        break;
      case 'getLocalStorage':
        methodName = MethodName.getLocalStorage;
        break;
      case 'removeLocalStroge':
        methodName = MethodName.removeLocalStroge;
        break;
      case 'clearLocalStroge':
        methodName = MethodName.clearLocalStroge;
        break;
      case 'deviceInfo':
        methodName = MethodName.deviceInfo;
      case 'qrcode':
        methodName = MethodName.qrcode;
        break;
      case 'pickerPhoto':
        methodName = MethodName.pickerPhoto;
        break;
      case 'openCamera':
        methodName = MethodName.openCamera;
        break;
      case 'navPop':
        methodName = MethodName.navPop;
        break;
      case 'toast':
        methodName = MethodName.toast;
        break;
      case 'reload':
        methodName = MethodName.reload;
        break;
      case 'networkInfo':
        methodName = MethodName.networkInfo;
        break;
      case 'connectivity':
        methodName = MethodName.connectivity;
        break;
      case 'setNavigationBarColor':
        methodName = MethodName.setNavigationBarColor;
        break;
      case 'httpRequest':
        methodName = MethodName.httpRequest;
        break;
      case 'localNotification':
        methodName = MethodName.localNotification;
        break;
      case 'fileUpload':
        methodName = MethodName.fileUpload;
        break;
      case 'fileDownload':
        methodName = MethodName.fileDownload;
        break;
      case 'setClipboard':
        methodName = MethodName.setClipboard;
        break;
      case 'getClipboard':
        methodName = MethodName.getClipboard;
        break;
      default:
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['sessionId'] = sessionId;
    data['methodName'] = methodName;
    data['params'] = params;
    return data;
  }
}

class SetLocalStorage {
  String? key;
  String? value;

  SetLocalStorage({this.key, this.value});

  SetLocalStorage.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class LoadFile {
  String? path;
  String? id;

  LoadFile({this.path, this.id});

  LoadFile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['path'] = path;
    return data;
  }
}

class PhotoParams {
  int? maxAssets;
  Color? themeColor;
  late bool keepScrollOffset;
  RequestType? requestType;
  List<String>? selectedAssetIds;

  PhotoParams({
    this.maxAssets,
    this.themeColor,
    this.requestType,
    this.selectedAssetIds,
    this.keepScrollOffset = false,
  });

  RequestType get type {
    return requestType ?? RequestType.common;
  }

  PhotoParams.fromJson(Map<String, dynamic> json) {
    maxAssets = json['maxAssets'];
    themeColor = getColor4Hex(json['themeColor']);
    keepScrollOffset = json['keepScrollOffset'] ?? false;
    selectedAssetIds = json['selectedAssetIds']?.cast<String>() ?? [];

    switch (json['requestType']) {
      case 'all':
        requestType = RequestType.all;
        break;
      case 'audio':
        requestType = RequestType.audio;
        break;
      case 'image':
        requestType = RequestType.image;
        break;
      case 'video':
        requestType = RequestType.video;
        break;
      case 'common':
      default:
        requestType = RequestType.common;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maxAssets'] = maxAssets;
    data['themeColor'] = themeColor;
    data['requestType'] = requestType;
    data['keepScrollOffset'] = keepScrollOffset;
    data['selectedAssetIds'] = selectedAssetIds;
    return data;
  }
}

class CameraParams {
  late bool enableAudio;
  late bool enableRecording;
  late bool enableTapRecording;
  late bool onlyEnableRecording;
  late Duration maximumRecordingDuration;
  late Duration minimumRecordingDuration;

  CameraParams({
    this.enableAudio = true,
    this.enableRecording = false,
    this.enableTapRecording = false,
    this.onlyEnableRecording = false,
    this.minimumRecordingDuration = const Duration(seconds: 1),
    this.maximumRecordingDuration = const Duration(seconds: 15),
  });

  CameraParams.fromJson(Map<String, dynamic> json) {
    enableAudio = json['enableAudio'] ?? true;
    enableRecording = json['enableRecording'] ?? false;
    enableTapRecording = json['enableTapRecording'] ?? false;
    onlyEnableRecording = json['onlyEnableRecording'] ?? false;
    minimumRecordingDuration = json['minimumRecordingDuration'] ?? const Duration(seconds: 1);
    maximumRecordingDuration = json['maximumRecordingDuration'] ?? const Duration(seconds: 15);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['enableAudio'] = enableAudio;
    data['enableRecording'] = enableRecording;
    data['onlyEnableRecording'] = onlyEnableRecording;
    data['enableTapRecording'] = enableTapRecording;
    data['maximumRecordingDuration'] = maximumRecordingDuration;
    return data;
  }
}

class ToastParams {
  late final String msg;
  late final Color? textColor;
  late final Color? backgroundColor;
  late final double? fontSize;
  late final ToastGravity? position;

  ToastParams({required this.msg, this.textColor, this.backgroundColor, this.fontSize, this.position});

  ToastParams.fromJson(Map<String, dynamic> json) {
    msg = json['msg'] ?? '';
    fontSize = json['fontSize'];
    textColor = getColor4Hex(json['textColor']);
    backgroundColor = getColor4Hex(json['backgroundColor']);

    switch (json['position']) {
      case 'top':
        position = ToastGravity.TOP;
        break;
      case 'topLeft':
        position = ToastGravity.TOP_LEFT;
        break;
      case 'topRight':
        position = ToastGravity.TOP_RIGHT;
        break;
      case 'bottom':
        position = ToastGravity.BOTTOM;
        break;
      case 'bottomLeft':
        position = ToastGravity.BOTTOM_LEFT;
        break;
      case 'bottomRight':
        position = ToastGravity.BOTTOM_RIGHT;
        break;
      case 'center':
        position = ToastGravity.CENTER;
        break;
      case 'centerLeft':
        position = ToastGravity.CENTER_LEFT;
        break;
      case 'centerRight':
        position = ToastGravity.CENTER_RIGHT;
        break;
      default:
        position = ToastGravity.BOTTOM;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['fontSize'] = fontSize;
    data['position'] = position;
    data['textColor'] = textColor;
    data['backgroundColor'] = backgroundColor;
    return data;
  }
}

class NetworkItem {
  final String name;
  final Future<String?> api;
  NetworkItem(this.api, this.name);
}

class HttpRequestConfig {
  late final String url;
  late final String? method;
  late final Duration? timeout;
  late final ResponseType? responseType;
  late final Map<String, dynamic>? data;
  late final Map<String, dynamic>? params;
  late final Map<String, dynamic>? headers;

  HttpRequestConfig(
      {required this.url, this.method, this.headers, this.params, this.data, this.timeout, this.responseType});

  HttpRequestConfig.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    data = json['data'];
    method = json['method'];
    headers = json['headers'];
    params = json['params'];
    timeout = json['timeout'] != null ? Duration(milliseconds: json['timeout']) : null;
    switch (json['responseType']) {
      case 'bytes':
        responseType = ResponseType.bytes;
        break;
      case 'plain':
        responseType = ResponseType.plain;
        break;
      case 'stream':
        responseType = ResponseType.stream;
        break;
      case 'json':
      default:
        responseType = ResponseType.json;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['method'] = method;
    data['headers'] = headers;
    data['params'] = params;
    data['data'] = this.data;
    data['timeout'] = timeout;
    data['responseType'] = responseType;
    return data;
  }
}

class LocalNotificationParams {
  late final String? title;
  late final String? body;
  late final String? payload;

  LocalNotificationParams({this.title, this.body, this.payload});

  LocalNotificationParams.fromJson(Map<String, dynamic> json) {
    body = json['body'];
    title = json['title'];
    payload = json['payload'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['body'] = body;
    data['title'] = title;
    data['payload'] = payload;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
