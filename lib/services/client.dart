import 'package:dio/dio.dart';
import 'package:flutter_main/types/postMessage.dart';

final dio = Dio();

Future<Response<dynamic>> download(String url, String savePath) async {
  return dio.downloadUri(Uri.parse(url), savePath, onReceiveProgress: (int count, int total) {
    print(['count', count]);
    print(['total', total]);
    print(['progress', total / total]);
  });
}

request(HttpRequestConfig config) {
  final path = config.url;

  return dio.request(
    path,
    data: config.data,
    queryParameters: config.params,
    options: Options(method: config.method, headers: config.headers, sendTimeout: config.timeout),
  );
}
