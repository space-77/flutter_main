import 'package:dio/dio.dart';

final dio = Dio();

Future<Response<dynamic>> download(String url, String savePath) async {
  return dio.downloadUri(Uri.parse(url), savePath, onReceiveProgress: (int count, int total) {
    print(['count', count]);
    print(['total', total]);
    print(['progress', total / total]);
  });
}
