import 'package:equatable/equatable.dart';

/// Base failure class for all domain-level errors.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure originating from the remote server.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Failure from the local cache / storage.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data could not be loaded.']);
}

/// Failure due to invalid input / validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure when a resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}

/// Failure when the user is not authorised.
class UnauthorisedFailure extends Failure {
  const UnauthorisedFailure([super.message = 'Unauthorised. Please log in again.']);
}
