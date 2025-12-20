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
      loginState.value = loginState.value.copyWith(
        email: emailController.text,
      );
    });

    passwordController.addListener(() {
      loginState.value = loginState.value.copyWith(
        password: passwordController.text,
      );
    });
  }

  /// Load remembered email if exists
  Future<void> _loadRememberedEmail() async {
    try {
      final user = await _storageService.getUser();
      if (user != null && user['email'] != null) {
        emailController.text = user['email'];
        loginState.value = loginState.value.copyWith(
          email: user['email'],
          rememberMe: true,
        );
        print('LoginViewModel: Loaded remembered email');
      }
    } catch (e) {
      print('LoginViewModel: Error loading remembered email: $e');
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    loginState.value = loginState.value.copyWith(
      isPasswordVisible: !loginState.value.isPasswordVisible,
    );
    print('LoginViewModel: Password visibility toggled: ${loginState.value.isPasswordVisible}');
  }

  /// Toggle remember me
  void toggleRememberMe(bool? value) {
    loginState.value = loginState.value.copyWith(
      rememberMe: value ?? false,
    );
    print('LoginViewModel: Remember me toggled: ${loginState.value.rememberMe}');
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
      _handleLoginError(response.message ?? "Something went wrong");
      return;
    }

    print("LoginViewModel: Login success");

    final data = response.data?["data"];       // Outer data
    final userData = data?["user"];            // Inner user object

    if (userData == null) {
      _handleLoginError("Invalid server response");
      return;
    }

    // Save user to local storage
    await _storageService.saveUser(userData);

    // Save dummy token to satisfy your ApiHandler header flow
    await _storageService.saveToken("temp_token_${DateTime.now().millisecondsSinceEpoch}");

    loginState.value = loginState.value.copyWith(
      successMessage: AppStrings.loginSuccess,
    );

    _showSnackbar(
      "Success",
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
      _showSnackbar('Error', AppStrings.emailRequired, AppColors.error);
      return false;
    }

    // Check if email is valid
    if (!loginState.value.isEmailValid) {
      _showSnackbar('Error', AppStrings.emailInvalid, AppColors.error);
      return false;
    }

    // Check if password is empty
    if (passwordController.text.isEmpty) {
      _showSnackbar('Error', AppStrings.passwordRequired, AppColors.error);
      return false;
    }

    // Check password length
    if (passwordController.text.length < 6) {
      _showSnackbar('Error', AppStrings.passwordMinLength, AppColors.error);
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

      // Save token to local storage
      await _storageService.saveToken(data['token']);
      print('LoginViewModel: Token saved');

        await _storageService.clear();
        await _storageService.clear();

      // Save user data to local storage
      await _storageService.saveUser(user);
      print('LoginViewModel: User data saved');

      // Update state with success message
      loginState.value = loginState.value.copyWith(
        successMessage: AppStrings.loginSuccess,
      );

      // Show success message
      _showSnackbar(
        'Success',
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
      _handleLoginError('Failed to process login data');
    }
  }

  /// Handle login error
  void _handleLoginError(String message) {
    loginState.value = loginState.value.copyWith(
      errorMessage: message,
    );

    _showSnackbar('Error', message, AppColors.error);
  }

  /// Navigate to forgot password screen
  void navigateToForgotPassword() {
    print('LoginViewModel: Navigate to forgot password');
    // TODO: Implement forgot password navigation
    _showSnackbar(
      'Info',
      'Forgot password feature coming soon',
      AppColors.info,
    );
  }

  /// Navigate to sign up screen
  void navigateToSignUp() {
    print('LoginViewModel: Navigate to sign up');
    // TODO: Implement sign up navigation
    _showSnackbar(
      'Info',
      'Sign up feature coming soon',
      AppColors.info,
    );
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
        icon ?? (title == 'Error' ? Icons.error : Icons.info),
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