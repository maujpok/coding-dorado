import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Crea un cliente HTTP por proveedor, cada uno con su URL base.
Dio createDio({
  required String baseUrl,
  List<Interceptor> interceptors = const [],
  bool logRequests = false,
  Duration timeout = const Duration(seconds: 10),
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll(interceptors);
  if (logRequests) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        logPrint: (message) => debugPrint(message.toString()),
      ),
    );
  }
  return dio;
}
