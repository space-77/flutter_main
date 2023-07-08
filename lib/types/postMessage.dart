enum MethodName {
  deviceInfo('deviceInfo');

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
      case 'deviceInfo':
        methodName = MethodName.deviceInfo;
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
