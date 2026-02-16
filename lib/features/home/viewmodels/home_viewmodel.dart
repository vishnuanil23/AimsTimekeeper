import 'package:aims_timekeeper/core/services/storage_service.dart';
import 'package:aims_timekeeper/data/repositories/attendance_repository.dart';
import 'package:aims_timekeeper/data/repositories/location_repository.dart';
import 'package:aims_timekeeper/utils/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeState {
  String userEmail;
  String userName;
  String currentTime;
  String currentDate;
  bool isPunchedIn;
  bool isLoading;
  bool isFetchingLocation;
  DateTime? lastPunchInTime;
  DateTime? lastPunchOutTime;
  int? attendanceId;
  String? locationText;

  HomeState({
    this.userEmail = "",
    this.userName = "User",
    String? currentTime,
    String? currentDate,
    this.isPunchedIn = false,
    this.isLoading = false,
    this.isFetchingLocation = false,
    this.lastPunchInTime,
    this.lastPunchOutTime,
    this.attendanceId,
    this.locationText,
  }) : currentTime = currentTime ?? _formatTime(DateTime.now()),
       currentDate = currentDate ?? _formatDate(DateTime.now());

  static String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}:"
      "${dt.second.toString().padLeft(2, '0')}";

  static String _formatDate(DateTime dt) {
    final day = dt.day;
    String suffix = 'th';
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];

    return "$day$suffix $month ${dt.year}";
  }

  // Computed properties for UI
  String get statusText => isPunchedIn ? "Punched In" : "Not Punched In";
  String get buttonText => isPunchedIn ? "Punch Out" : "Punch In";

  String get lastActionTime {
    final dt = lastPunchOutTime ?? lastPunchInTime;
    if (dt == null) return '-';
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String get formattedWorkDuration {
    if (lastPunchInTime == null) return '00:00:00';
    final end = lastPunchOutTime ?? DateTime.now();
    final diff = end.difference(lastPunchInTime!);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class HomeViewModel extends GetxController {
  final AttendanceRepository _attendanceRepo = Get.put(AttendanceRepository());
  final LocationRepository _locationRepo = Get.put(LocationRepository());
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
      if (s.userName.isEmpty) s.userName = "User";

      s.attendanceId = user["attendanceId"];
      s.isPunchedIn = user["isLoggedIn"] ?? false;

      // Load cached location if exists
      s.locationText = _storage.getCachedLocation();
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
        s.currentTime = HomeState._formatTime(now);
        s.currentDate = HomeState._formatDate(now);
      });

      return true;
    });
  }

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

    // Simulate delay for smooth UI transition
    await Future.delayed(const Duration(milliseconds: 600));

    // Fetch real location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final lat = position.latitude;
    final lng = position.longitude;

    homeState.update((s) {
      if (s == null) return;
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
      // Reverse geocode ONLY on Punch IN
      final locationText = await _locationRepo.getAreaFromCoordinates(lat, lng);

      if (locationText != null) {
        homeState.update((s) {
          if (s == null) return;
          s.locationText = locationText;
        });

        await _storage.saveCachedLocation(locationText);
      }

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
          s.isLoading = false;
        });

        _showSuccess("Punch IN recorded");
      } catch (e) {
        _showError("Error: $e");
        homeState.update((s) => s?.isLoading = false);
      }

      return;
    }

    // PUNCH OUT
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
        s.locationText = null; // Clear from state
        s.isLoading = false;
      });

      await _storage.clearCachedLocation(); // Clear from storage

      _showSuccess("Punch OUT recorded");
    } catch (e) {
      _showError("Error: $e");
      homeState.update((s) => s?.isLoading = false);
    }
  }

  /// Logout
  Future<void> logout() async {
    final rememberedEmail = await _storage.getRememberedEmail();

    await _storage.clearAll();

    if (rememberedEmail != null) {
      await _storage.saveRememberedEmail(rememberedEmail);
    }

    homeState.update((s) {
      if (s == null) return;
      s.isPunchedIn = false;
      s.lastPunchInTime = null;
      s.lastPunchOutTime = null;
      s.attendanceId = null;
      s.userEmail = rememberedEmail ?? "";
      s.locationText = null;
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
