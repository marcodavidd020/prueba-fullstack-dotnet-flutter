import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sol_catalog/core/error/failure.dart';

class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _translate(err),
      ),
    );
  }

  Failure _translate(DioException err) => switch (err.type) {
    DioExceptionType.cancel => const CancelledFailure(),

    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => const NetworkFailure(
      'La conexión tardó demasiado. Intentá de nuevo.',
    ),

    DioExceptionType.connectionError => _connectionError(err),

    DioExceptionType.badCertificate => const NetworkFailure(
      'El certificado del servidor no es válido.',
    ),

    DioExceptionType.badResponse => _byHttpStatus(err.response),

    DioExceptionType.unknown =>
      err.error is SocketException
          ? const NetworkFailure()
          : const UnexpectedFailure(),
  };

  Failure _connectionError(DioException err) {
    final host = err.requestOptions.uri.host;
    return NetworkFailure(
      'No pudimos conectarnos a $host. '
      'Verificá que el backend esté corriendo y que la URL sea la correcta '
      'para esta plataforma.',
    );
  }

  Failure _byHttpStatus(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = response?.data;
    final detail = _readDetail(body);

    return switch (status) {
      400 => ValidationFailure(
        detail ?? 'Los datos enviados no son válidos.',
        errors: _readFieldErrors(body),
      ),
      401 || 403 => UnauthorizedFailure(
        detail ?? const UnauthorizedFailure().message,
      ),
      404 => NotFoundFailure(detail ?? const NotFoundFailure().message),
      409 || 412 => ConflictFailure(detail ?? const ConflictFailure().message),
      429 => const ServerFailure(
        'Hiciste demasiadas solicitudes seguidas. Esperá un momento.',
      ),
      >= 500 => ServerFailure(detail ?? const ServerFailure().message),
      _ => UnexpectedFailure(detail ?? const UnexpectedFailure().message),
    };
  }

  String? _readDetail(dynamic body) {
    if (body is! Map<String, dynamic>) return null;

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) return detail;

    final title = body['title'];
    if (title is String && title.isNotEmpty) return title;

    return null;
  }

  Map<String, List<String>> _readFieldErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return const {};

    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return const {};

    return {
      for (final entry in errors.entries)
        entry.key: switch (entry.value) {
          final List<dynamic> list => list.map((e) => e.toString()).toList(),
          final Object value => [value.toString()],
          _ => <String>[],
        },
    };
  }
}
