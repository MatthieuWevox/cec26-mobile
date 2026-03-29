/// API configuration file.
/// ⚠️ Before deployment, update [baseUrl] with your actual API domain.
/// Change [baseUrl] to switch between test and production environments.
class ApiConfig {
  /// Base URL of the API (without trailing slash).
  /// Example: 'https://cec2026.example.com/api'
  static const String baseUrl = 'http://192.168.1.56:8000/api';

  // Public routes
  static String get news => '$baseUrl/news';
  static String get meetings => '$baseUrl/meetings';
  static String get companies => '$baseUrl/companies';
  static String get members => '$baseUrl/members';
  static String get login => '$baseUrl/login';

  // Private routes
  static String get logout => '$baseUrl/logout';
  static String get me => '$baseUrl/me';
  static String get mePassword => '$baseUrl/me/password';
  static String get meCompany => '$baseUrl/me/company';
  static String get recommendationsReceived =>
      '$baseUrl/recommendations/received';
  static String get recommendationsSent => '$baseUrl/recommendations/sent';
  static String get recommendations => '$baseUrl/recommendations';
  static String get thanksReceived => '$baseUrl/thanks/received';
  static String get thanksSent => '$baseUrl/thanks/sent';
  static String get thanks => '$baseUrl/thanks';

  static String meetingGuests(int meetingId) =>
      '$baseUrl/meetings/$meetingId/guests';
}
