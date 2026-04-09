import 'package:get/get.dart';
import '../../core/network/api_handler.dart';
import '../../utils/constants.dart';

class LeaveRepository {
  final ApiHandler _apiHandler = Get.find<ApiHandler>();

  Future<ApiResponse> getLeaveTypes() async {
    return _apiHandler.get(AppConstants.leaveTypesEndpoint);
  }
}
