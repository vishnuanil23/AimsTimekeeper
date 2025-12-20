import 'package:aims_timekeeper/core/services/storage_service.dart';
import 'package:get/get.dart';
import '../../../core/network/api_handler.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print('SplashBinding: Initializing dependencies...');
    
    // Initialize core services (permanent = stays in memory throughout app lifecycle)
    // Storage Service - for local data storage
    Get.put(StorageService(), permanent: true);
    
    // API Handler - for network requests
    Get.put(ApiHandler(), permanent: true);
    
    // Initialize splash viewmodel (lazyPut = created when first accessed)
    Get.lazyPut<SplashViewModel>(() => SplashViewModel());
    
    print('SplashBinding: Dependencies initialized successfully');
  }
}