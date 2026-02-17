import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildRememberAndForgot(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                // const SizedBox(height: 24),
                // _buildDivider(),
                // const SizedBox(height: 24),
                // _buildSignUpSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build app logo
  Widget _buildLogo() {
    return Center(
      child: Hero(
        tag: 'app_logo',
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.access_time_rounded,
            size: 50,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Build title
  Widget _buildTitle() {
    return const Text(
      AppStrings.loginTitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Build subtitle
  Widget _buildSubtitle() {
    return const Text(
      AppStrings.loginSubtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Build email input field
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.email, Icons.email_outlined),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: AppStrings.emailHint,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.textSecondary,
              ),
              errorText: controller.loginState.value.emailError,
              filled: true,
              fillColor: AppColors.surface,
              border: _buildInputBorder(),
              enabledBorder: _buildInputBorder(),
              focusedBorder: _buildInputBorder(isFocused: true),
              errorBorder: _buildInputBorder(isError: true),
              focusedErrorBorder: _buildInputBorder(isError: true),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build password input field
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.password, Icons.lock_outline),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.login(),
            decoration: InputDecoration(
              hintText: AppStrings.passwordHint,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              errorText: controller.loginState.value.passwordError,
              filled: true,
              fillColor: AppColors.surface,
              border: _buildInputBorder(),
              enabledBorder: _buildInputBorder(),
              focusedBorder: _buildInputBorder(isFocused: true),
              errorBorder: _buildInputBorder(isError: true),
              focusedErrorBorder: _buildInputBorder(isError: true),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build field label
  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build input border
  OutlineInputBorder _buildInputBorder({
    bool isFocused = false,
    bool isError = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color:
            isError
                ? AppColors.error
                : isFocused
                ? AppColors.primary
                : AppColors.border,
        width: isFocused ? 2 : 1,
      ),
    );
  }

  /// Build remember me and forgot password row
  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.loginState.value.rememberMe,
                  onChanged: controller.toggleRememberMe,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.rememberMe,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build login button
  Widget _buildLoginButton() {
    return Obx(() {
      final isLoading = controller.isLoading;
      final isFormValid = controller.loginState.value.isFormValid;

      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient:
              isFormValid && !isLoading
                  ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  )
                  : null,
          color: isFormValid && !isLoading ? null : AppColors.border,
          boxShadow:
              isFormValid && !isLoading
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading || !isFormValid ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.loginButton,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
        ),
      );
    });
  }

  /// Build sign up section
  /* Widget _buildSignUpSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: controller.navigateToSignUp,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  } */
}
