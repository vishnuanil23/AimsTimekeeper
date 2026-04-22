import 'package:aims_timekeeper/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../utils/strings.dart';
import '../../../utils/colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../models/login_model.dart';

class LoginViewModel extends GetxController {
  // Dependencies
  final AuthRepository _authRepository = Get.put(AuthRepository());
  final StorageService _storageService = Get.find<StorageService>();

  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Observable state - Single source of truth
  final Rx<LoginModel> loginState = LoginModel().obs;

  // Getters for easy access
  bool get isLoading => loginState.value.isLoading;
  bool get isPasswordVisible => loginState.value.isPasswordVisible;
  String get email => loginState.value.email;
  String get password => loginState.value.password;

  @override
  void onInit() {
    super.onInit();
    print('LoginViewModel: Initialized');
    _setupListeners();
    _loadRememberedEmail();
  }

  /// Setup listeners for text field changes
  void _setupListeners() {
    emailController.addListener(() {
      loginState.value = loginState.value.copyWith(email: emailController.text);
    });

    passwordController.addListener(() {
      loginState.value = loginState.value.copyWith(
        password: passwordController.text,
      );
    });
  }

  /// Load remembered email if exists
  Future<void> _loadRememberedEmail() async {
    final rememberedEmail = await _storageService.getRememberedEmail();

    if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
      emailController.text = rememberedEmail;
      loginState.value = loginState.value.copyWith(
        email: rememberedEmail,
        rememberMe: true,
      );
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    loginState.value = loginState.value.copyWith(
      isPasswordVisible: !loginState.value.isPasswordVisible,
    );
    print(
      'LoginViewModel: Password visibility toggled: ${loginState.value.isPasswordVisible}',
    );
  }

  /// Toggle remember me
  void toggleRememberMe(bool? value) async {
    final newValue = value ?? false;

    loginState.value = loginState.value.copyWith(rememberMe: newValue);

    if (newValue) {
      // Save email immediately when user checks remember me
      await _storageService.saveRememberedEmail(emailController.text.trim());
    } else {
      // Clear if user unchecks remembering
      await _storageService.clearRememberedEmail();
    }
  }

  /// Main login method (REAL API)
  Future<void> login() async {
    print('LoginViewModel: Real login attempt started');

    // Clear previous errors
    loginState.value = loginState.value.copyWith(
      errorMessage: null,
      successMessage: null,
    );

    // Validate inputs
    if (!_validateInputs()) {
      print('LoginViewModel: Validation failed');
      return;
    }

    loginState.value = loginState.value.copyWith(isLoading: true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Call repository → API
      final response = await _authRepository.login(email, password);

      if (!response.success) {
        print("LoginViewModel: Login failed - ${response.message}");
        _handleLoginError(response.message ?? AppStrings.somethingWentWrong);
        return;
      }

      print("LoginViewModel: Login success");

      final data = response.data?["data"]; // Outer data
      final userData = data?["user"]; // Inner user object

      if (userData == null) {
        _handleLoginError(AppStrings.invalidServerResponse);
        return;
      }

      final hrmsUser = _authRepository.parseUser(userData);
      // Save user as JSON map
      await _storageService.saveUser(hrmsUser.toJson());
      await _storageService.saveLoginStatus(true);
      await _storageService.savePunchStatus(hrmsUser.isPunchedIn);
      if (loginState.value.rememberMe) {
        await _storageService.saveRememberedEmail(emailController.text.trim());
      } else {
        await _storageService.clearRememberedEmail();
      }
      loginState.value = loginState.value.copyWith(
        successMessage: AppStrings.loginSuccess,
      );

      _showSnackbar(
        AppStrings.success,
        AppStrings.loginSuccess,
        AppColors.success,
        icon: Icons.check_circle,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.home); // Move to home
    } catch (e) {
      print("LoginViewModel: Real login exception - $e");
      _handleLoginError(AppStrings.somethingWentWrong);
    } finally {
      loginState.value = loginState.value.copyWith(isLoading: false);
    }
  }

  /// Validate form inputs
  bool _validateInputs() {
    // Check if email is empty
    if (emailController.text.trim().isEmpty) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.emailRequired,
        AppColors.error,
      );
      return false;
    }

    // Check if email is valid
    if (!loginState.value.isEmailValid) {
      _showSnackbar(AppStrings.error, AppStrings.emailInvalid, AppColors.error);
      return false;
    }

    // Check if password is empty
    if (passwordController.text.isEmpty) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.passwordRequired,
        AppColors.error,
      );
      return false;
    }

    // Check password length
    if (passwordController.text.length < 6) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.passwordMinLength,
        AppColors.error,
      );
      return false;
    }

    print('LoginViewModel: Validation passed');
    return true;
  }

  /// Handle successful login
  Future<void> _handleLoginSuccess(dynamic data) async {
    try {
      // Parse user model from response
      final user = _authRepository.parseUser(data['user']);

      await _storageService.clear();
      await _storageService.clear();

      // Save user data to local storage
      await _storageService.saveUser(user.toJson());
      await _storageService.saveLoginStatus(true);
      await _storageService.savePunchStatus(user.isPunchedIn);
      print('LoginViewModel: User data saved');

      // Update state with success message
      loginState.value = loginState.value.copyWith(
        successMessage: AppStrings.loginSuccess,
      );

      // Show success message
      _showSnackbar(
        AppStrings.success,
        AppStrings.loginSuccess,
        AppColors.success,
        icon: Icons.check_circle,
      );

      // Wait a bit for user to see success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to home screen
      print('LoginViewModel: Navigating to home');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      print('LoginViewModel: Error handling login success: $e');
      _handleLoginError(AppStrings.failedToProcessLogin);
    }
  }

  /// Handle login error
  void _handleLoginError(String message) {
    loginState.value = loginState.value.copyWith(errorMessage: message);

    _showSnackbar(AppStrings.error, message, AppColors.error);
  }

  /// Show snackbar message
  void _showSnackbar(
    String title,
    String message,
    Color backgroundColor, {
    IconData? icon,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: AppColors.white,
      icon: Icon(
        icon ?? (title == AppStrings.error ? Icons.error : Icons.info),
        color: AppColors.white,
      ),

      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  /// Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    loginState.value = LoginModel();
    print('LoginViewModel: Form cleared');
  }

  @override
  void onClose() {
    print('LoginViewModel: Disposing controllers');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
