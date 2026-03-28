/// Exceptions thrown by the data layer; caught and mapped to [Failure]s
/// by repositories.
class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  const AppException(this.message, [this.stackTrace]);
  @override
  String toString() => 'AppException: $message';
}

class StorageException extends AppException {
  const StorageException(super.message, [super.stackTrace]);
  @override
  String toString() => 'StorageException: $message';
}

class NetworkException extends AppException {
  final int? statusCode;

  // Can't mix positional super params with explicit super() call,
  // so pass both positional args explicitly via the initializer.
  const NetworkException(
    String message, {
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

class ParseException extends AppException {
  const ParseException(super.message, [super.stackTrace]);
  @override
  String toString() => 'ParseException: $message';
}

class NotImplementedException extends AppException {
  const NotImplementedException([super.message = 'Not implemented']);
}