// lib/features/home/viewmodels/home_viewmodel.dart

import 'package:aims_timekeeper/core/services/location_service.dart';
import 'package:aims_timekeeper/data/repositories/attendance_repository.dart';
import 'package:aims_timekeeper/utils/date_time_utils.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../utils/colors.dart';

class HomeState {
  String userEmail;
  String userName;

  String currentTime;
  String currentDate;

  bool hasLocation;
  double? currentLatitude;
  double? currentLongitude;
  String? locationText;
  bool isFetchingLocation;

  bool isPunchedIn;
  DateTime? lastPunchInTime;
  DateTime? lastPunchOutTime;
  int? attendanceId;

  bool isLoading;

  String statusText;
  String buttonText;

  HomeState({
    this.userEmail = "",
    this.userName = "",
    String? currentTime,
    String? currentDate,
    int? attendanceId,
    this.hasLocation = false,
    this.currentLatitude,
    this.currentLongitude,
    this.locationText,
    this.isFetchingLocation = false,
    this.isPunchedIn = false,
    this.lastPunchInTime,
    this.lastPunchOutTime,
    this.isLoading = false,
    String? statusText,
    String? buttonText,
  })  : currentTime = currentTime ?? _formatTime(DateTime.now()),
        currentDate = currentDate ?? DateTimeUtils.formatDate(DateTime.now()),
        statusText = statusText ?? 'Not punched in',
        buttonText = buttonText ?? 'Punch In';

  static String _formatTime(DateTime dt) =>
      '${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  String get lastActionTime {
    final dt = lastPunchOutTime ?? lastPunchInTime;
    if (dt == null) return '-';
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} '
        '${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String get formattedWorkDuration {
    if (lastPunchInTime == null) return '00:00:00';
    final end = lastPunchOutTime ?? DateTime.now();
    final diff = end.difference(lastPunchInTime!);

    return '${_two(diff.inHours)}:'
        '${_two(diff.inMinutes.remainder(60))}:'
        '${_two(diff.inSeconds.remainder(60))}';
  }
}

class HomeViewModel extends GetxController {
  final AttendanceRepository _attendanceRepo = Get.put(AttendanceRepository());
  final StorageService _storage = Get.find<StorageService>();
  final Rx<HomeState> homeState = HomeState().obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserDetails();
    _startClock();
  }

  /// Load stored user email + firstName
  Future<void> _loadUserDetails() async {
     final user = await _storage.getUser();

  if (user == null) return;

  homeState.update((s) {
    if (s == null) return;

    s.userEmail = user["email"] ?? "";
    s.userName = "${user["firstName"]} ${user["lastName"]}".trim();
    
    // IMPORTANT:
    s.attendanceId = user["attendanceId"];
    s.isPunchedIn = user["isLoggedIn"] ?? false;

    if (s.isPunchedIn) {
      s.statusText = "Punched In";
      s.buttonText = "Punch Out";
    } else {
      s.statusText = "Not Punched In";
      s.buttonText = "Punch In";
    }
  });
        }

  /// Header name getter used in UI
  String get userName => homeState.value.userName;

  /// Live time updater every second
  void _startClock() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();

      homeState.update((s) {
        if (s == null) return;
        s.currentTime =
            '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';
       s.currentDate = DateTimeUtils.formatDate(now);
      });

      return true;
    });
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Pull-to-refresh action
  Future<void> refreshData() async {
    homeState.update((s) {
      if (s == null) return;
      s.isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    homeState.update((s) {
      if (s == null) return;
      s.isLoading = false;
    });
  }

  /// Punch In / Punch Out 
 Future<void> togglePunch() async {
  if (homeState.value.isLoading || homeState.value.isFetchingLocation) return;

  homeState.update((s) {
    if (s == null) return;
    s.isLoading = true;
    s.isFetchingLocation = true;
  });

  // Simulate location fetching
  await Future.delayed(const Duration(milliseconds: 600));

 // Fetch real location
    final position = await LocationService.getCurrentLocation();

    if (position == null) {
      _showError("Location permission denied");
      homeState.update((s) => s?.isFetchingLocation = false);
      return;
    }

    final lat = position.latitude;
    final lng = position.longitude;
    final address = await LocationService.getAddressFromCoordinates(lat, lng);

  homeState.update((s) {
    if (s == null) return;
    s.currentLatitude = lat;
    s.currentLongitude = lng;
    s.locationText = address ?? "Location Available";
    s.hasLocation = true;
    s.isFetchingLocation = false;
  });

  // Get user
  final user = await _storage.getUser();
  final int? userId = user?["id"];

  if (userId == null) {
    _showError("User ID missing");
    homeState.update((s) => s?.isLoading = false);
    return;
  }

  // PUNCH IN
  if (!homeState.value.isPunchedIn) {
    try {
      final response = await _attendanceRepo.punchIn(
        userId: userId,
        latitude: lat,
        longitude: lng,
      );

      if (!response.success) {
        _showError(response.message ?? "Punch IN failed");
        homeState.update((s) => s?.isLoading = false);
        return;
      }

      final data = response.data["data"];
      final dt = DateTime.parse(data["lastPunchTime"]);

      homeState.update((s) {
        if (s == null) return;
        s.isPunchedIn = true;
        s.lastPunchInTime = dt;
        s.lastPunchOutTime = null;
        s.attendanceId = data["attendanceId"];   
        print("Saved AttendanceID: ${data["attendanceId"]}");

        s.statusText = "Punched In";
        s.buttonText = "Punch Out";
        s.isLoading = false;
      });

      _showSuccess("Punch IN recorded");

    } catch (e) {
      _showError("Error: $e");
      homeState.update((s) => s?.isLoading = false);
    }

    return;
  }

  // 3️⃣ PUNCH OUT
  try {
    final attendanceId = homeState.value.attendanceId;

    if (attendanceId == null) {
      _showError("Cannot Punch Out — attendanceId missing");
      homeState.update((s) => s?.isLoading = false);
      return;
    }

    final response = await _attendanceRepo.punchOut(
      userId: userId,
      attendanceId: attendanceId,
      latitude: lat,
      longitude: lng,
    );

    if (!response.success) {
      _showError(response.message ?? "Punch OUT failed");
      homeState.update((s) => s?.isLoading = false);
      return;
    }

    final data = response.data["data"];
    final dt = DateTime.parse(data["lastPunchOutTime"]);

    homeState.update((s) {
      if (s == null) return;
      s.isPunchedIn = false;
      s.lastPunchOutTime = dt;
      s.statusText = "Punched Out";
      s.buttonText = "Punch In";
      s.isLoading = false;
    });

    _showSuccess("Punch OUT recorded");

  } catch (e) {
    _showError("Error: $e");
    homeState.update((s) => s?.isLoading = false);
  }
}


  /// Logout 
 Future<void> logout() async {
  // Load remembered email
  final rememberedEmail = await _storage.getRememberedEmail();

  // Clear everything except remembered email
  await _storage.clearAll();

  // Restore remembered email if exists
  if (rememberedEmail != null) {
    await _storage.saveRememberedEmail(rememberedEmail);
  }

  // Reset UI state
  homeState.update((s) {
    if (s == null) return;
    s.isPunchedIn = false;
    s.lastPunchInTime = null;
    s.lastPunchOutTime = null;
    s.attendanceId = null;
    s.userEmail = rememberedEmail ?? "";
    s.statusText = "Not Punched In";
    s.buttonText = "Punch In";
    s.hasLocation = false;
    s.currentLatitude = null;
    s.currentLongitude = null;
  });

  Get.offAllNamed('/login');
}

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'Success',
      msg,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
    );
  }
}
