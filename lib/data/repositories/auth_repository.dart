import 'package:aims_timekeeper/core/network/api_handler.dart';
import 'package:aims_timekeeper/features/login/models/hrms_user_model.dart';
import 'package:aims_timekeeper/utils/constants.dart';

class AuthRepository {
  final ApiHandler _api = ApiHandler();

  Future<ApiResponse> login(String email, String password) {
    return _api.post(AppConstants.loginEndpoint, {
      "email": email,
      "password": password,
    });
  }

  // Parse user only if needed later
  HrmsUserModel parseUser(Map<String, dynamic> json) {
    return HrmsUserModel.fromJson(json);
  }
}
