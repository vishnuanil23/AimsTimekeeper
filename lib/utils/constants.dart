class AppConstants {
  // static const String baseUrl = "http://10.0.2.2:5078";
  static const String baseUrl = "http://111.118.176.204:8067";

  static const String loginEndpoint = '/auth/login';
  static const String punchInEndpoint = '/attendance/punch';
  static const String punchOutEndpoint = '/attendance/punch';
  static const String attendanceStatusEndpoint = '/attendance/status';
  static const String leaveTypesEndpoint = '/leave/types';
  static const String leaveApplyEndpoint = '/leave/apply';
  static const String leaveHistoryEndpoint = '/leave/history';

  // External APIs
  static const String nominatimUrl =
      'https://nominatim.openstreetmap.org/reverse';
  static const String userAgent = 'hrms-attendance-app';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String isPunchedInKey = 'is_punched_in';

  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
