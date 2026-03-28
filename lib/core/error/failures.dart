import 'package:equatable/equatable.dart';

/// Domain-layer error representations.  Repositories catch exceptions and
/// convert them to Failures so the domain layer stays framework-free.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
  @override
  String toString() => '$runtimeType: $message';
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});
  @override
  List<Object?> get props => [message, statusCode];
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String msg = 'An unexpected error occurred'])
      : super(msg);
}