import 'package:flutter/material.dart';
import 'package:flutter_main/types/webDirInfo.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

final Future<SharedPreferences> storage = SharedPreferences.getInstance();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// const apiPaht = '/apis';
const scheme = 'jsbridge';
const schemeBase = '$scheme://maxrocky.app';
const assetsPaht = '/apis/files/assets'; // 通过 scheme 获取资源前缀
const assetsPaht4Url = 'file';
const WEB_ASSETS_PATH = 'assets/www';
const WEB_ASSETS_PATH_INDEX = 'index.html';
final schemeUrl = join(schemeBase, WEB_ASSETS_PATH_INDEX);

const SCHEME_SESSIONID = -1;
final defaultVersion = Version.parse('1.0.0');
final defaultDir = WebDirInfo(path: WEB_ASSETS_PATH, indexFile: WEB_ASSETS_PATH_INDEX, version: Version.parse('1.0.0'));

// storage key
const webVersion = 'WEB_ASSETS_VERSION';
const webAssetsInfoListkey = 'WEB_ASSETS_LIST';
