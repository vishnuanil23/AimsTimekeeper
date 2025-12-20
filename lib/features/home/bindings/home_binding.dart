import 'package:get/get.dart';
import '../../../core/services/location_service.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('HomeBinding: Initializing dependencies...');
    
    // Initialize location service
    Get.put(LocationService(), permanent: true);
    
    // Initialize home viewmodel
    Get.lazyPut<HomeViewModel>(() => HomeViewModel());
    
    print('HomeBinding: Dependencies initialized successfully');
  }
}