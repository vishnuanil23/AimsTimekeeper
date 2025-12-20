import 'package:aims_timekeeper/core/services/storage_service.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../models/splash_model.dart';

class SplashViewModel extends GetxController {
  // Dependency injection
  final StorageService _storageService = Get.find<StorageService>();

  // Observable state - This is the single source of truth for splash screen
  final Rx<SplashModel> splashState = SplashModel().obs;

  // Getters for easy access to state properties
  bool get isInitialized => splashState.value.isInitialized;
  bool get isCheckingAuth => splashState.value.isCheckingAuth;
  String? get errorMessage => splashState.value.errorMessage;
  double get progress => splashState.value.progress;

  @override
  void onInit() {
    super.onInit();
    print('SplashViewModel: Initializing...');
    _initializeApp();
  }

  /// Initialize the application
  /// This method runs when splash screen loads
  Future<void> _initializeApp() async {
    try {
      print('SplashViewModel: Starting initialization...');
      
      // Step 1: Initialize storage service
      await _initializeStorage();

      // Step 2: Simulate loading (you can replace with actual initialization tasks)
      await _simulateLoading();

      // Step 3: Check authentication
      await _checkAuthentication();

      // Step 4: Navigate to appropriate screen
      await _navigateToNextScreen();

    } catch (e) {
      print('SplashViewModel: Error during initialization: $e');
      _handleInitializationError(e.toString());
    }
  }

  /// Initialize storage service
  Future<void> _initializeStorage() async {
    try {
      print('SplashViewModel: Initializing storage...');
      await _storageService.init();
      _updateProgress(0.3);
      print('SplashViewModel: Storage initialized successfully');
    } catch (e) {
      print('SplashViewModel: Storage initialization failed: $e');
      throw Exception('Failed to initialize storage: $e');
    }
  }

  /// Simulate loading process
  /// Replace this with actual initialization tasks like:
  /// - Loading configuration
  /// - Initializing Firebase
  /// - Fetching initial data
  Future<void> _simulateLoading() async {
    print('SplashViewModel: Simulating loading...');
    
    // Simulate progress
    for (int i = 1; i <= 3; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      _updateProgress(0.3 + (i * 0.2));
      print('SplashViewModel: Progress: ${0.3 + (i * 0.2)}');
    }
    
    print('SplashViewModel: Loading complete');
  }

  /// Check if user is authenticated
  Future<void> _checkAuthentication() async {
    try {
      print('SplashViewModel: Checking authentication status...');
      
      splashState.value = splashState.value.copyWith(
        isCheckingAuth: true,
      );

      // Check if user has valid token
      final isLoggedIn = await _storageService.isLoggedIn();
      
      print('SplashViewModel: User logged in: $isLoggedIn');
      
      _updateProgress(1.0);

      splashState.value = splashState.value.copyWith(
        isCheckingAuth: false,
        isInitialized: true,
      );

    } catch (e) {
      print('SplashViewModel: Authentication check failed: $e');
      throw Exception('Failed to check authentication: $e');
    }
  }

  /// Navigate to the next screen based on authentication status
  Future<void> _navigateToNextScreen() async {
    // Add small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final isLoggedIn = await _storageService.isLoggedIn();

    print('SplashViewModel: Navigating to ${isLoggedIn ? 'Home' : 'Login'} screen');

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Update progress value
  void _updateProgress(double value) {
    splashState.value = splashState.value.copyWith(progress: value);
  }

  /// Handle initialization errors
  void _handleInitializationError(String error) {
    print('SplashViewModel: Handling error: $error');
    
    splashState.value = splashState.value.copyWith(
      isInitialized: false,
      isCheckingAuth: false,
      errorMessage: error,
    );

    // Show error and navigate to login after delay
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.login);
    });
  }

  /// Retry initialization (in case of error)
  void retryInitialization() {
    print('SplashViewModel: Retrying initialization...');
    splashState.value = SplashModel(); // Reset state
    _initializeApp();
  }

  @override
  void onClose() {
    print('SplashViewModel: Disposing...');
    super.onClose();
  }
}