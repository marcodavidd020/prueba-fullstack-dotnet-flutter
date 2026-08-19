import 'package:dio/dio.dart';
import 'package:sol_catalog/core/config/app_config.dart';

class ApiKeyInterceptor extends Interceptor {
  const ApiKeyInterceptor(this._config);

  final AppConfig _config;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = _config.apiKey;

    if (key.isNotEmpty) {
      options.headers['X-Api-Key'] = key;
    }

    handler.next(options);
  }
}
