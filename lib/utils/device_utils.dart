import 'package:nb_utils/nb_utils.dart';

enum DeviceType {
  web('web'),
  ios('IOS'),
  macOS('macOS'),
  linux('linux'),
  android('android'),
  windows('windows');

  final String name;
  const DeviceType(this.name);
}

String? getDevType() {
  if (isIOS) {
    return DeviceType.ios.name;
  } else if (isAndroid) {
    return DeviceType.android.name;
  } else if (isWeb) {
    return DeviceType.web.name;
  } else if (isMacOS) {
    return DeviceType.macOS.name;
  } else if (isLinux) {
    return DeviceType.linux.name;
  } else if (isWindows) {
    return DeviceType.windows.name;
  }
  return null;
}
