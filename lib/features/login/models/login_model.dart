class LoginModel {
  final String email;
  final String password;
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final String? successMessage;
  final bool rememberMe;

  LoginModel({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.successMessage,
    this.rememberMe = false,
  });

  /// Creates a new instance with updated values
  /// This maintains immutability of the model
  LoginModel copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    String? successMessage,
    bool? rememberMe,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  /// Validation methods
  bool get isEmailValid {
    if (email.isEmpty) return false;
    // Email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool get isPasswordValid => password.length >= 6;

  bool get isFormValid => isEmailValid && isPasswordValid;

  /// Error getters
  String? get emailError {
    if (email.isEmpty) return null;
    if (!isEmailValid) return 'Please enter a valid email';
    return null;
  }

  String? get passwordError {
    if (password.isEmpty) return null;
    if (!isPasswordValid) return 'Password must be at least 6 characters';
    return null;
  }

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @override
  String toString() {
    return 'LoginModel(email: $email, isLoading: $isLoading, isPasswordVisible: $isPasswordVisible, hasError: $hasError)';
  }
}
