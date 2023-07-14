class BridgeValue {
  late int code;
  String? data;
  String? msg;
  int? sessionId;

  BridgeValue({this.sessionId, this.code = 0, this.data, this.msg = '"success"'});

  BridgeValue.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'];
    msg = json['msg'];
    sessionId = json['sessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['data'] = this.data;
    data['msg'] = msg;
    data['sessionId'] = sessionId;
    return data;
  }
}
