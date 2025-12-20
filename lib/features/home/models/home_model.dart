class HomeModel {
  final bool isPunchedIn;
  final bool isLoading;
  final bool isFetchingLocation;
  final String userName;
  final String userEmail;
  final String currentTime;
  final String currentDate;
  final DateTime? lastPunchInTime;
  final DateTime? lastPunchOutTime;
  final String? errorMessage;
  final String? successMessage;
  final Duration? todayWorkDuration;
  final double? currentLatitude;
  final double? currentLongitude;

  HomeModel({
    this.isPunchedIn = false,
    this.isLoading = false,
    this.isFetchingLocation = false,
    this.userName = 'User',
    this.userEmail = '',
    this.currentTime = '',
    this.currentDate = '',
    this.lastPunchInTime,
    this.lastPunchOutTime,
    this.errorMessage,
    this.successMessage,
    this.todayWorkDuration,
    this.currentLatitude,
    this.currentLongitude,
  });

  HomeModel copyWith({
    bool? isPunchedIn,
    bool? isLoading,
    bool? isFetchingLocation,
    String? userName,
    String? userEmail,
    String? currentTime,
    String? currentDate,
    DateTime? lastPunchInTime,
    DateTime? lastPunchOutTime,
    String? errorMessage,
    String? successMessage,
    Duration? todayWorkDuration,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return HomeModel(
      isPunchedIn: isPunchedIn ?? this.isPunchedIn,
      isLoading: isLoading ?? this.isLoading,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      currentTime: currentTime ?? this.currentTime,
      currentDate: currentDate ?? this.currentDate,
      lastPunchInTime: lastPunchInTime ?? this.lastPunchInTime,
      lastPunchOutTime: lastPunchOutTime ?? this.lastPunchOutTime,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      todayWorkDuration: todayWorkDuration ?? this.todayWorkDuration,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }

  String get statusText => isPunchedIn ? 'Checked In' : 'Checked Out';
  String get buttonText => isPunchedIn ? 'Punch Out' : 'Punch In';
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  String get formattedWorkDuration {
    if (todayWorkDuration == null) return '0h 0m';
    final hours = todayWorkDuration!.inHours;
    final minutes = todayWorkDuration!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String get lastActionTime {
    final time = isPunchedIn ? lastPunchInTime : lastPunchOutTime;
    if (time == null) return 'N/A';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'HomeModel(isPunchedIn: $isPunchedIn, hasLocation: $hasLocation, lat: $currentLatitude, long: $currentLongitude)';
  }
}