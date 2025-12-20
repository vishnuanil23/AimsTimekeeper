class SplashModel {
  final bool isInitialized;
  final bool isCheckingAuth;
  final String? errorMessage;
  final double progress;

  SplashModel({
    this.isInitialized = false,
    this.isCheckingAuth = false,
    this.errorMessage,
    this.progress = 0.0,
  });

  /// Creates a new instance with updated values
  /// This maintains immutability of the model
  SplashModel copyWith({
    bool? isInitialized,
    bool? isCheckingAuth,
    String? errorMessage,
    double? progress,
  }) {
    return SplashModel(
      isInitialized: isInitialized ?? this.isInitialized,
      isCheckingAuth: isCheckingAuth ?? this.isCheckingAuth,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  /// Check if splash is loading
  bool get isLoading => !isInitialized || isCheckingAuth;

  /// Check if there's an error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @override
  String toString() {
    return 'SplashModel(isInitialized: $isInitialized, isCheckingAuth: $isCheckingAuth, progress: $progress, error: $errorMessage)';
  }
}