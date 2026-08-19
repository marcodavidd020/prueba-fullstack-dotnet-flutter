import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sol_catalog/core/config/app_config.dart';
import 'package:sol_catalog/core/error/failure.dart';
import 'package:sol_catalog/core/network/interceptors/api_key_interceptor.dart';
import 'package:sol_catalog/core/network/interceptors/error_interceptor.dart';

Dio buildDio(AppConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${config.apiBaseUrl}/api/v1',
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      contentType: 'application/json',
    ),
  );

  dio.interceptors.addAll([
    ApiKeyInterceptor(config),
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (line) => debugPrint(line.toString()),
      ),
    const ErrorInterceptor(),
  ]);

  return dio;
}

extension DioResponseX on DioException {
  Failure get failure =>
      error is Failure ? error! as Failure : const UnexpectedFailure();
}
