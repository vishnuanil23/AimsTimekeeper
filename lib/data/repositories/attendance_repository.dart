import 'package:get/get.dart';
import '../../core/network/api_handler.dart';
import '../../utils/constants.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiHandler _apiHandler = Get.find<ApiHandler>();

  /// Punch in with latitude and longitude
  Future<ApiResponse> punchIn({
    required int userId,
    required double latitude,
    required double longitude,
  }) async {
    print('AttendanceRepository: Punch in request with location');
    print('AttendanceRepository: Lat: $latitude, Long: $longitude');
    
    return await _apiHandler.post(
      AppConstants.punchInEndpoint,
      {
         "userId": userId,
        "action": "IN",
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  /// Punch out with latitude and longitude
Future<ApiResponse> punchOut({
  required int userId,
  required int attendanceId,
  required double latitude,
  required double longitude,
}) async {
  return await _apiHandler.post(
     AppConstants.punchOutEndpoint,   
    {
      "userId": userId,
      "attendanceId": attendanceId,
      "latitude": latitude,
      "longitude": longitude,
      "action": "OUT"
    },
  );
}

  /// Get attendance status
  Future<ApiResponse> getAttendanceStatus() async {
    print('AttendanceRepository: Get attendance status');
    
    return await _apiHandler.get(AppConstants.attendanceStatusEndpoint);
  }

  /// Parse attendance from API response
  AttendanceModel parseAttendance(Map<String, dynamic> data) {
    print('AttendanceRepository: Parsing attendance data');
    return AttendanceModel.fromJson(data);
  }
}
