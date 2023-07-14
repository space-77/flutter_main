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
