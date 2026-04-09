import 'package:get/get.dart';
import '../../core/network/api_handler.dart';
import '../../utils/constants.dart';

class LeaveRepository {
  final ApiHandler _apiHandler = Get.find<ApiHandler>();

  Future<ApiResponse> getLeaveTypes() async {
    return _apiHandler.get(AppConstants.leaveTypesEndpoint);
  }

  Future<ApiResponse> getLeaveHistory({required int employeeId}) async {
    return _apiHandler.get(
      '${AppConstants.leaveHistoryEndpoint}?employeeId=$employeeId',
    );
  }

  Future<ApiResponse> applyLeave({
    required int employeeId,
    required int leaveTypeId,
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveSessionDuration,
    required String reason,
  }) async {
    return _apiHandler.post(AppConstants.leaveApplyEndpoint, {
      'employeeID': employeeId,
      'leaveTypeID': leaveTypeId,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'leaveSessionDuration': leaveSessionDuration,
      'reason': reason,
    });
  }
}
