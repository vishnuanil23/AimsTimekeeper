// lib/features/home/viewmodels/home_viewmodel.dart

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

    final firstName = user?["firstName"] ?? "";
    final lastName = user?["lastName"] ?? "";
    final email = user?["email"] ?? "";
    final bool punchedIn = user?["isLoggedIn"] ?? false;

      String fullName = "";

      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        fullName = "$firstName $lastName";
      } else if (firstName.isNotEmpty) {
        fullName = firstName;
      } else if (email.contains("@")) {
        fullName = email.split('@').first;
      } else {
        fullName = "User";
      }

      homeState.update((s) {
        if (s == null) return;
        s.userEmail = email;
        s.userName = fullName;
        s.isPunchedIn = punchedIn;
        s.statusText = punchedIn ? "Punched In" : "Not punched in";
        s.buttonText = punchedIn ? "Punch Out" : "Punch In";
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

  // Set loading states
  homeState.update((s) {
    if (s == null) return;
    s.isLoading = true;
    s.isFetchingLocation = true;
  });

  // Simulate location fetching
  await Future.delayed(const Duration(milliseconds: 600));

  const lat = 25.2048;
  const lng = 55.2708;

  homeState.update((s) {
    if (s == null) return;
    s.currentLatitude = lat;
    s.currentLongitude = lng;
    s.hasLocation = true;
    s.isFetchingLocation = false;
  });

  await Future.delayed(const Duration(milliseconds: 300));

  //  If NOT punched in → Call PUNCH IN API
  if (!homeState.value.isPunchedIn) {
    try {
      // Get saved user
      final user = await _storage.getUser();
      final int? userId = user?["id"];

      if (userId == null) {
        _showError("User ID missing");
        homeState.update((s) => s?.isLoading = false);
        return;
      }

      // Call API
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

      // Parse API data
      final data = response.data["data"];
      final dt = DateTime.parse(data["lastPunchTime"]);

      // Update state based on API response
      homeState.update((s) {
        if (s == null) return;
        s.isPunchedIn = true;
        s.lastPunchInTime = dt;
        s.attendanceId = data["attendanceId"];
        s.lastPunchOutTime = null;
        s.statusText = "Punched In";
        s.buttonText = "Punch Out";
        s.isLoading = false;
      });

      _showSuccess("Punch In Done!");

    } catch (e) {
      _showError("Error: $e");
      homeState.update((s) => s?.isLoading = false);
    }

    return;
  }

  // 3️⃣ If already punched in → (Keep existing demo Punch OUT)
  homeState.update((s) {
    if (s == null) return;
    s.isPunchedIn = false;
    s.lastPunchOutTime = DateTime.now();
    s.statusText = "Punched Out";
    s.buttonText = "Punch In";
    s.isLoading = false;
  });

  _showSuccess("Punch Out Done!");
}


  /// Logout (demo)
  void logout() {
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
