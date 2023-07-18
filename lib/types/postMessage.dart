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
  deviceInfo('deviceInfo'),
  openCamera('openCamera'),
  pickerPhoto('pickerPhoto'),
  networkInfo('networkInfo'),
  connectivity('connectivity'),
  setLocalStorage('setLocalStorage'),
  getLocalStorage('getLocalStorage'),
  clearLocalStroge('clearLocalStroge'),
  removeLocalStroge('removeLocalStroge');

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
