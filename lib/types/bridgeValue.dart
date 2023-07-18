class BridgeValue {
  late int code;
  String? api;
  String? data;
  String? msg;
  int? sessionId;
  String? error;

  BridgeValue({this.sessionId, this.code = 0, this.data, this.api, this.error, this.msg = '"success"'});

  BridgeValue.fromJson(Map<String, dynamic> json) {
    api = json['api'];
    msg = json['msg'];
    code = json['code'];
    data = json['data'];
    error = json['error'];
    sessionId = json['sessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['msg'] = msg;
    data['code'] = code;
    data['data'] = this.data;
    data['error'] = error;
    data['sessionId'] = sessionId;
    return data;
  }
}
