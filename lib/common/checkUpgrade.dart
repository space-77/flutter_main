import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_main/config/config.dart';
import 'package:flutter_main/services/client.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:flutter_main/utils/console.dart';
import 'package:flutter_main/utils/list_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';

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

  return WebDirInfo(
      path: join(zipFilePath, fileDirName), indexFile: WEB_ASSETS_PATH_INDEX, version: Version.parse('1.0.1'));
}

checkUpgrade(List<WebDirInfo> webAssetsInfoList) async {
  const fileUrl = 'http://192.168.70.100:8080/dist.zip';

  // 代码存放目录
  final dirPath = join((await getTemporaryDirectory()).path, 'www');
  final fileName = basename(fileUrl);

  try {
    await download(fileUrl, join(dirPath, fileName));
    final info = unzip(dirPath, fileName);
    if (info == null) return;
    final prefs = await storage;
    prefs.setString(webVersion, info.version.toString());
    webAssetsInfoList.add(info);
    final webAssetsList = webAssetsInfoList.map((e) => e.toString()).toList();
    prefs.setStringList(webAssetsInfoListkey, webAssetsList);
  } catch (e) {
    console.error(e);
  }
}

Future<WebDirInfo> init() async {
  final prefs = await storage;
  final webAssetsPath = prefs.getString(webVersion);
  final version = webAssetsPath != null ? Version.parse(webAssetsPath) : defaultVersion;

  // prefs.remove(webAssetsInfoListkey);
  final webAssetsInfoStr = prefs.getStringList(webAssetsInfoListkey) ?? [];
  final webAssetsInfoList = webAssetsInfoStr.map((e) => WebDirInfo.fromJson(json.decode(e))).toList();

  if (webAssetsInfoList.find((item) => item.version == version) == null) {
    checkUpgrade(webAssetsInfoList);
  }

  late final WebDirInfo webFileInfo;
  try {
    webFileInfo = [...webAssetsInfoList, defaultDir].firstWhere((item) => item.version == version);
  } catch (e) {
    return defaultDir;
  }

  // TODO webFileInfo 索引文件如果不存在
  if (File(join(webFileInfo.path, webFileInfo.indexFile)).existsSync()) return webFileInfo;
  return defaultDir;
}
