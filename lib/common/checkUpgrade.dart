import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_main/services/client.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class WebDirInfo {
  final String path;
  final String name;
  WebDirInfo(this.path, this.name);
}

WebDirInfo? unzip(String zipFilePath, String fileName) {
  final filePath = join(zipFilePath, fileName);
  if (!File(filePath).existsSync()) return null;
  // 从磁盘读取Zip文件。
  List<int> bytes = File(filePath).readAsBytesSync();
  // 解码Zip文件
  Archive archive = ZipDecoder().decodeBytes(bytes);

  // TODO 检测文件夹是否存在

  final fileDirName = basenameWithoutExtension(filePath);
  // 将Zip存档的内容解压缩到磁盘。
  for (ArchiveFile file in archive) {
    final filePath = join(zipFilePath, fileDirName, file.name);
    if (file.isFile) {
      List<int> data = file.content;
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(filePath).create(recursive: true);
    }
  }

  return WebDirInfo(filePath, fileName);
}

checkUpgrade() async {
  const fileUrl = 'http://192.168.70.100:8080/dist.zip';

  final dirPath = join((await getTemporaryDirectory()).path, 'www');
  final fileName = basename(fileUrl);

  await download(fileUrl, join(dirPath, fileName));
  unzip(dirPath, fileName);
}
