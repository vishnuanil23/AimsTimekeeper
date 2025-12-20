import 'package:get/get.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    print('LoginBinding: Initializing dependencies...');
    
    // Initialize login viewmodel
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
    
    print('LoginBinding: Dependencies initialized successfully');
  }
}