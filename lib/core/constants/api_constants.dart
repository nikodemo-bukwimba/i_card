/// Reserved for future remote-sync endpoints.
abstract class ApiConstants {
  static const String baseUrl    = 'https://api.issubi.com';
  static const String apiVersion = 'v1';
  static const String apiBase    = '$baseUrl/$apiVersion';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String headerContentType   = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String contentTypeJson     = 'application/json';
}