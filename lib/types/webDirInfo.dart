import 'dart:convert';

import 'package:version/version.dart';

class WebDirInfo {
  late final String path;
  late final Version version;
  late final String indexFile;

  WebDirInfo({required this.path, required this.indexFile, required this.version});

  WebDirInfo.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    version = Version.parse(json['version']);
    indexFile = json['indexFile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['version'] = version.toString();
    data['indexFile'] = indexFile;
    return data;
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
