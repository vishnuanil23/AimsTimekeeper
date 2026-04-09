import 'package:get/get.dart';
import '../../../data/repositories/leave_repository.dart';
import '../viewmodels/leave_viewmodel.dart';

class LeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveRepository>(() => LeaveRepository());
    Get.lazyPut<LeaveViewModel>(() => LeaveViewModel());
  }
}
