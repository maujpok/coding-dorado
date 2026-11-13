import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Contenido de `test/fixtures/<path>`.
String readFixture(String path) =>
    File('test/fixtures/$path').readAsStringSync();

Object? readJsonFixture(String path) => jsonDecode(readFixture(path));

/// Cuenta las peticiones que llegan al borde HTTP.
class RequestCounter extends Interceptor {
  final List<Uri> requests = [];

  int get count => requests.length;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options.uri);
    handler.next(options);
  }
}

/// Dio sin red: [mock] responde todas las peticiones; [counter] las cuenta.
Dio mockedDio(
  Interceptor mock, {
  RequestCounter? counter,
  String baseUrl = 'https://mock.local/api',
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  if (counter != null) dio.interceptors.add(counter);
  dio.interceptors.add(mock);
  return dio;
}

/// Interceptor que responde siempre con [data] (HTTP 200).
class StaticResponseInterceptor extends Interceptor {
  StaticResponseInterceptor(this.data);

  Object? data;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: data),
    );
  }
}
