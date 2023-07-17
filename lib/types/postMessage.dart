import 'package:flutter/material.dart';
import 'package:flutter_main/utils/color_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum MethodName {
  assets('assets'),
  setLocalStorage('setLocalStorage'),
  getLocalStorage('getLocalStorage'),
  removeLocalStroge('removeLocalStroge'),
  clearLocalStroge('clearLocalStroge'),
  deviceInfo('deviceInfo'),
  qrcode('qrcode'),
  pickerPhoto('pickerPhoto'),
  openCamera('openCamera'),
  navPop('navPop'),
  reLoad('reLoad');

  final String name;
  const MethodName(this.name);
}

class MaxRockyMes {
  late int sessionId;
  String? params;
  MethodName? methodName;

  MaxRockyMes({required this.sessionId, this.methodName, this.params});

  MaxRockyMes.fromJson(Map<String, dynamic> json) {
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
      case 'reLoad':
        methodName = MethodName.reLoad;
        break;
      default:
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    themeColor = json['themeColor'] != null ? HexColor.fromHex(json['themeColor']) : null;
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
