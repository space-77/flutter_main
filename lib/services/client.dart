import 'package:dio/dio.dart';
import 'package:flutter_main/types/postMessage.dart';
import 'package:flutter_main/utils/console.dart';

final dio = Dio();

Future<Response<dynamic>> download(String url, String savePath) async {
  return dio.downloadUri(Uri.parse(url), savePath, onReceiveProgress: (int count, int total) {
    console.log(['count', count]);
    console.log(['total', total]);
    console.log(['progress', total / total]);
  });
}

getOptions(HttpRequestConfig config) {
  return Options(method: config.method, headers: config.headers, sendTimeout: config.timeout);
}

Future<Response<dynamic>> request(HttpRequestConfig config) {
  final path = config.url;

  return dio.request(
    path,
    data: config.data,
    options: getOptions(config),
    queryParameters: config.params,
  );
}
