import 'package:aims_timekeeper/core/network/api_handler.dart';

class AuthRepository {
  final ApiHandler _api = ApiHandler();

  Future<ApiResponse> login(String email, String password) {
    return _api.post("auth/login", {
      "email": email,
      "password": password,
    });
  }

  // Parse user only if needed later
  Map<String, dynamic> parseUser(Map<String, dynamic> json) {
    return {
      "id": json["id"],
      "email": json["email"],
      "firstName": json["firstName"],
      "lastName": json["lastName"],
      "employeeCode": json["employeeCode"],
      "isLoggedIn": json["isLoggedIn"],
    };
  }
}
