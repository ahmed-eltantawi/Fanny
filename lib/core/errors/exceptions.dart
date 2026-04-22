/// Exception thrown when the server returns a non-2xx response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Server error', this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Exception thrown due to network/connectivity issues.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when local storage operations fail.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}
