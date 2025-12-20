import 'package:aims_timekeeper/features/splash/models/splash_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashView extends GetView<SplashViewModel> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildAppTitle(),
                const SizedBox(height: 8),
                _buildAppSubtitle(),
                const Spacer(flex: 2),
                _buildLoadingSection(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build gradient background
  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primaryDark,
        ],
      ),
    );
  }

  /// Build app logo with animation
  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.access_time_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build app title with animation
  Widget _buildAppTitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: const Text(
              AppStrings.splashTitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build app subtitle
  Widget _buildAppSubtitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: const Text(
            AppStrings.splashSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  /// Build loading section with progress indicator
  Widget _buildLoadingSection() {
    return Obx(() {
      final state = controller.splashState.value;

      // Show error state
      if (state.hasError) {
        return _buildErrorState(state.errorMessage!);
      }

      // Show loading state
      return Column(
        children: [
          _buildLoadingIndicator(),
          const SizedBox(height: 16),
          _buildLoadingText(state),
          const SizedBox(height: 12),
          _buildProgressBar(state.progress),
        ],
      );
    });
  }

  /// Build circular loading indicator
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
      ),
    );
  }

  /// Build loading text based on state
  Widget _buildLoadingText(SplashModel state) {
    String text = 'Initializing...';
    
    if (state.isCheckingAuth) {
      text = 'Checking authentication...';
    } else if (state.progress > 0.8) {
      text = 'Almost ready...';
    } else if (state.progress > 0.5) {
      text = 'Loading resources...';
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Build progress bar
  Widget _buildProgressBar(double progress) {
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: AppColors.white,
        ),
        const SizedBox(height: 16),
        const Text(
          'Initialization Failed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: controller.retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}