/// Thrown when the backend returns `{ "success": false, "error": {...} }`
/// or when the HTTP call itself fails.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => message;
}
