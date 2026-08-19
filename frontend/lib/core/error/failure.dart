sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => 'Failure: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No pudimos conectarnos. Revisá tu conexión a internet.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'El servidor no pudo procesar la solicitud. Intentá de nuevo en unos minutos.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'No encontramos el producto. Puede que lo hayan eliminado.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors = const {}});

  final Map<String, List<String>> errors;

  String? forField(String field) {
    final messages = errors[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'No tenés permiso para realizar esta acción.',
  ]);
}

final class ConflictFailure extends Failure {
  const ConflictFailure([
    super.message = 'Otra persona modificó este producto. Recargá para ver el precio actual.',
  ]);
}

final class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Operación cancelada.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocurrió un error inesperado.']);
}
