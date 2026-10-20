/// Error surfaced from the network layer with a user-readable message.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
