import 'package:get/get.dart';
import '../viewmodels/leave_viewmodel.dart';

class LeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveViewModel>(() => LeaveViewModel());
  }
}
