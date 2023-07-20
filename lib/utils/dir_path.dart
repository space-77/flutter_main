import 'package:path_provider/path_provider.dart';

Future<String> temporaryDirPath() async {
  return (await getTemporaryDirectory()).path;
}
