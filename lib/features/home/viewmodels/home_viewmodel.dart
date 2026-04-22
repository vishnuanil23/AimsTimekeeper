import 'package:aims_timekeeper/core/services/storage_service.dart';
import 'package:aims_timekeeper/utils/date_time_utils.dart';
import 'package:aims_timekeeper/data/repositories/attendance_repository.dart';
import 'package:aims_timekeeper/data/repositories/location_repository.dart';
import 'package:aims_timekeeper/utils/colors.dart';
import 'package:aims_timekeeper/core/services/location_service.dart';
import 'package:aims_timekeeper/utils/strings.dart';
import 'package:flutter/widgets.dart';
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
       currentDate = currentDate ?? _formatDate(DateTime.now()),
       greeting = DateTimeUtils.getGreeting(DateTime.now());

  String greeting;

  static String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  static String _formatDate(DateTime dt) {
    final day = dt.day;
    String suffix = AppStrings.th;
    if (day >= 11 && day <= 13) {
      suffix = AppStrings.th;
    } else {
      switch (day % 10) {
        case 1:
          suffix = AppStrings.st;
          break;
        case 2:
          suffix = AppStrings.nd;
          break;
        case 3:
          suffix = AppStrings.rd;
          break;
        default:
          suffix = AppStrings.th;
      }
    }

    final months = [
      AppStrings.jan,
      AppStrings.feb,
      AppStrings.mar,
      AppStrings.apr,
      AppStrings.may,
      AppStrings.jun,
      AppStrings.jul,
      AppStrings.aug,
      AppStrings.sep,
      AppStrings.oct,
      AppStrings.nov,
      AppStrings.dec,
    ];

    final month = months[dt.month - 1];

    return "$day$suffix $month ${dt.year}";
  }

  // Computed properties for UI
  String get statusText =>
      isPunchedIn ? AppStrings.punchIn : AppStrings.notPunchedIn;
  String get buttonText =>
      isPunchedIn ? AppStrings.punchOut : AppStrings.punchIn;

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

class HomeViewModel extends GetxController with WidgetsBindingObserver {
  final AttendanceRepository _attendanceRepo = Get.put(AttendanceRepository());
  final LocationRepository _locationRepo = Get.put(LocationRepository());
  final StorageService _storage = Get.find<StorageService>();
  final Rx<HomeState> homeState = HomeState().obs;
  final RxString currentTime = HomeState._formatTime(DateTime.now()).obs;
  final RxString currentDate = HomeState._formatDate(DateTime.now()).obs;
  final RxString workDuration = '00:00:00'.obs;
  bool _isClockRunning = false;
  bool _isOperationInProgress = false;
  DateTime? _workDurationStartedAt;
  DateTime? _lastSuccessfulLocalPunchInAt;
  static const Duration _localPunchSyncProtectionWindow = Duration(minutes: 2);

  bool get isOperationInProgress => _isOperationInProgress;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
    _startClock();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isOperationInProgress) {
          syncAttendanceStatusFromServer();
        }
        _startClock();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      default:
        _persistCurrentAttendanceState();
        _isClockRunning = false;
        break;
    }
  }

  @override
  void onClose() {
    _isClockRunning = false;
    WidgetsBinding.instance.removeObserver(this);
    _persistCurrentAttendanceState();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    await _loadUserDetails();
    await syncAttendanceStatusFromServer();
  }

  /// Load stored user email + firstName
  Future<void> _loadUserDetails() async {
    final user = await _storage.getUser();
    final isPunchedIn = await _storage.getPunchStatus();

    if (user == null) return;

    homeState.update((s) {
      if (s == null) return;

      s.userEmail = user["email"] ?? "";
      s.userName = "${user["firstName"]} ${user["lastName"]}".trim();
      if (s.userName.isEmpty) s.userName = "User";

      s.attendanceId = user["attendanceId"];
      s.isPunchedIn =
          isPunchedIn ||
          (_readBool(user["isPunchedIn"]) ??
              _readBool(user["isLoggedIn"]) ??
              false);
      s.lastPunchInTime = _parseDateTime(
        user["lastPunchInTime"] ?? user["lastPunchTime"],
      );
      s.lastPunchOutTime = _parseDateTime(user["lastPunchOutTime"]);

      // Load cached location if exists
      s.locationText = _storage.getCachedLocation();
    });

    if (homeState.value.isPunchedIn) {
      _workDurationStartedAt ??= homeState.value.lastPunchInTime;
    } else {
      _workDurationStartedAt = null;
    }

    _refreshClockValues();
  }

  Future<void> syncAttendanceStatusFromServer() async {
    if (_isOperationInProgress) return;

    final user = await _storage.getUser();
    final userId = _readInt(user?["id"]);

    if (user == null || userId == null) return;

    try {
      final response = await _attendanceRepo.getAttendanceStatus(
        userId: userId,
      );

      if (_isOperationInProgress) return;

      if (!response.success) return;

      final data = _responseData(response.data);
      if (data == null) return;

      final isPunchedIn =
          _readBool(data["isPunchedIn"]) ??
          _readBool(data["isLoggedIn"]) ??
          _readBool(data["isCheckedIn"]) ??
          _readBool(data["active"]) ??
          _readStatus(data["status"]) ??
          false;
      final attendanceId = _readInt(data["attendanceId"]);
      final lastPunchInTime = _parseDateTime(
        data["lastPunchInTime"] ?? data["lastPunchTime"],
      );
      final lastPunchOutTime = _parseDateTime(data["lastPunchOutTime"]);

      if (_shouldIgnoreStaleStatusAfterLocalPunchIn(
        isPunchedIn: isPunchedIn,
        attendanceId: attendanceId,
      )) {
        return;
      }

      await _saveAttendanceFallback(
        user: user,
        isPunchedIn: isPunchedIn,
        attendanceId: attendanceId,
        lastPunchInTime: lastPunchInTime,
        lastPunchOutTime: lastPunchOutTime,
      );

      if (!isPunchedIn) {
        await _storage.clearCachedLocation();
      }

      homeState.update((s) {
        if (s == null) return;
        s.isPunchedIn = isPunchedIn;
        s.attendanceId = attendanceId;
        s.lastPunchInTime = lastPunchInTime;
        s.lastPunchOutTime = lastPunchOutTime;
        if (!isPunchedIn) s.locationText = null;
      });
      _workDurationStartedAt =
          isPunchedIn ? (_workDurationStartedAt ?? lastPunchInTime) : null;
      _refreshClockValues();
    } catch (_) {}
  }

  /// Header name getter used in UI
  String get userName => homeState.value.userName;

  /// Live time updater every second
  void _startClock() {
    if (_isClockRunning) return;

    _isClockRunning = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (!_isClockRunning || isClosed) return false;

      final now = DateTime.now();
      _refreshClockValues(now);

      return _isClockRunning && !isClosed;
    });
  }

  void _refreshClockValues([DateTime? now]) {
    final current = now ?? DateTime.now();
    currentTime.value = HomeState._formatTime(current);
    currentDate.value = HomeState._formatDate(current);
    workDuration.value = _formatCurrentWorkDuration(current);
  }

  String _formatCurrentWorkDuration(DateTime now) {
    final state = homeState.value;
    final startedAt = _workDurationStartedAt;

    if (!state.isPunchedIn) return state.formattedWorkDuration;
    if (startedAt == null) return '00:00:00';

    final diff = now.difference(startedAt);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Pull-to-refresh action
  Future<void> refreshData() async {
    if (_isOperationInProgress || homeState.value.isLoading) return;

    homeState.update((s) {
      if (s == null) return;
      s.isLoading = true;
    });

    try {
      await syncAttendanceStatusFromServer();
    } finally {
      if (!_isOperationInProgress) {
        homeState.update((s) {
          if (s == null) return;
          s.isLoading = false;
        });
      }
    }
  }

  /// Punch In / Punch Out
  Future<void> togglePunch() async {
    if (_isOperationInProgress ||
        homeState.value.isLoading ||
        homeState.value.isFetchingLocation) {
      return;
    }

    _isOperationInProgress = true;
    homeState.update((s) {
      if (s == null) return;
      s.isLoading = true;
      s.isFetchingLocation = true;
    });

    try {
      // Simulate delay for smooth UI transition
      await Future.delayed(const Duration(milliseconds: 600));

      // Fetch real location - handles permission requests
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          Get.defaultDialog(
            title: AppStrings.error,
            middleText: AppStrings.locationPermissionPermanent,
            textConfirm: AppStrings.openSettings,
            textCancel: AppStrings.cancel,
            confirmTextColor: AppColors.white,
            onConfirm: () {
              Geolocator.openAppSettings();
              Get.back();
            },
          );
        } else {
          _showError(AppStrings.locationPermissionDenied);
        }

        return;
      }

      final lat = position.latitude;
      final lng = position.longitude;

      // Fetch address for API (needed for backend)
      final locationText =
          await _locationRepo.getAreaFromCoordinates(lat, lng) ??
          "Unknown Location";

      // Show the freshly resolved location while the punch request is pending.
      // Persist it only after a successful punch-in.
      homeState.update((s) {
        if (s == null) return;
        s.isFetchingLocation = false;
        s.locationText = locationText;
      });

      // Get user
      final user = await _storage.getUser();
      final userId = _readInt(user?["id"]);

      if (user == null || userId == null) {
        _showError(AppStrings.userIdMissing);
        return;
      }

      // PUNCH IN
      if (!homeState.value.isPunchedIn) {
        final response = await _attendanceRepo.punchIn(
          userId: userId,
          latitude: lat,
          longitude: lng,
          location: locationText,
        );

      if (!response.success) {
          _showError(response.message ?? AppStrings.punchInFailed);
          // Location fetched but discarded on failure
          return;
        }

        final data = response.data["data"];
        final isPunchedIn = _readBool(data["isPunchedIn"]) ?? true;
        final responseAttendanceId = _readInt(data["attendanceId"]);
        final dt = _parseDateTime(
          data["lastPunchInTime"] ?? data["lastPunchTime"],
        );

        if (dt == null) {
          _showError(AppStrings.invalidServerResponse);
          return;
        }

        // SUCCESS: Now update UI and cache
        await _storage.saveCachedLocation(locationText);
        await _saveAttendanceFallback(
          user: user,
          isPunchedIn: isPunchedIn,
          attendanceId: responseAttendanceId,
          lastPunchInTime: dt,
          lastPunchOutTime: null,
        );

        homeState.update((s) {
          if (s == null) return;
          s.isPunchedIn = isPunchedIn;
          s.lastPunchInTime = dt;
          s.lastPunchOutTime = null;
          s.attendanceId = responseAttendanceId;
          s.locationText = locationText;
        });
        _workDurationStartedAt = isPunchedIn ? DateTime.now() : null;
        _lastSuccessfulLocalPunchInAt = isPunchedIn ? DateTime.now() : null;
        _refreshClockValues();

        _showSuccess(AppStrings.punchInRecorded);

        return;
      }

      // PUNCH OUT
      final attendanceId = homeState.value.attendanceId;

      if (attendanceId == null) {
        _showError(AppStrings.attendanceIdMissing);
        return;
      }

      final response = await _attendanceRepo.punchOut(
        userId: userId,
        attendanceId: attendanceId,
        latitude: lat,
        longitude: lng,
        location: locationText,
      );

      if (!response.success) {
        _showError(response.message ?? AppStrings.punchOutFailed);
        return;
      }

      final data = response.data["data"];
      final isPunchedIn = _readBool(data["isPunchedIn"]) ?? false;
      final responseAttendanceId = _readInt(data["attendanceId"]);
      final dt = _parseDateTime(data["lastPunchOutTime"]);

      if (dt == null) {
        _showError(AppStrings.invalidServerResponse);
        return;
      }

      final latestUser = await _storage.getUser();

      if (latestUser != null) {
        await _saveAttendanceFallback(
          user: latestUser,
          isPunchedIn: isPunchedIn,
          attendanceId: isPunchedIn ? responseAttendanceId : null,
          lastPunchInTime: homeState.value.lastPunchInTime,
          lastPunchOutTime: dt,
        );
      }

      homeState.update((s) {
        if (s == null) return;
        s.isPunchedIn = isPunchedIn;
        s.attendanceId = isPunchedIn ? responseAttendanceId : null;
        s.lastPunchOutTime = dt;
        if (!isPunchedIn) s.locationText = null; // Clear from state
      });
      _workDurationStartedAt = isPunchedIn ? homeState.value.lastPunchInTime : null;
      _lastSuccessfulLocalPunchInAt = isPunchedIn ? DateTime.now() : null;
      _refreshClockValues();

      await _storage.clearCachedLocation(); // Clear from storage

      _showSuccess(AppStrings.punchOutRecorded);
    } catch (e) {
      _showError("${AppStrings.error}: $e");
    } finally {
      _isOperationInProgress = false;
      homeState.update((s) {
        if (s == null) return;
        s.isLoading = false;
        s.isFetchingLocation = false;
      });
    }
  }

  /// Logout
  Future<void> logout() async {
    final rememberedEmail = await _storage.getRememberedEmail();

    await _storage.clearSessionData();

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
    _workDurationStartedAt = null;
    _refreshClockValues();

    Get.offAllNamed('/login');
  }

  void _showError(String msg) {
    Get.snackbar(
      AppStrings.error,
      msg,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      AppStrings.success,
      msg,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
    );
  }

  Map<String, dynamic>? _responseData(dynamic responseData) {
    if (responseData is! Map) return null;

    final data = responseData["data"];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    return Map<String, dynamic>.from(responseData);
  }

  Future<void> _saveAttendanceFallback({
    required Map<String, dynamic> user,
    required bool isPunchedIn,
    required int? attendanceId,
    required DateTime? lastPunchInTime,
    required DateTime? lastPunchOutTime,
  }) async {
    user["isPunchedIn"] = isPunchedIn;
    user.remove("isLoggedIn");
    user["attendanceId"] = attendanceId;
    user["lastPunchInTime"] = lastPunchInTime?.toIso8601String();
    user["lastPunchTime"] = lastPunchInTime?.toIso8601String();
    user["lastPunchOutTime"] = lastPunchOutTime?.toIso8601String();

    await _storage.saveUser(user);
    await _storage.savePunchStatus(isPunchedIn);
  }

  Future<void> _persistCurrentAttendanceState() async {
    final user = await _storage.getUser();
    if (user == null) return;

    final state = homeState.value;
    await _saveAttendanceFallback(
      user: user,
      isPunchedIn: state.isPunchedIn,
      attendanceId: state.attendanceId,
      lastPunchInTime: state.lastPunchInTime,
      lastPunchOutTime: state.lastPunchOutTime,
    );
  }

  bool? _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == "true" || normalized == "1") return true;
      if (normalized == "false" || normalized == "0") return false;
    }
    return null;
  }

  bool? _readStatus(dynamic value) {
    if (value is! String) return null;

    final normalized = value.trim().toLowerCase();
    if (normalized == "in" ||
        normalized == "punch_in" ||
        normalized == "punched_in" ||
        normalized == "checked_in" ||
        normalized == "active") {
      return true;
    }
    if (normalized == "out" ||
        normalized == "punch_out" ||
        normalized == "punched_out" ||
        normalized == "checked_out" ||
        normalized == "inactive") {
      return false;
    }
    return null;
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool _shouldIgnoreStaleStatusAfterLocalPunchIn({
    required bool isPunchedIn,
    required int? attendanceId,
  }) {
    if (isPunchedIn || !homeState.value.isPunchedIn) return false;

    final localPunchInAt = _lastSuccessfulLocalPunchInAt;
    if (localPunchInAt == null) return false;

    final isRecentlyPunchedIn =
        DateTime.now().difference(localPunchInAt) <
        _localPunchSyncProtectionWindow;
    if (!isRecentlyPunchedIn) return false;

    final localAttendanceId = homeState.value.attendanceId;
    return attendanceId == null ||
        (localAttendanceId != null && attendanceId != localAttendanceId);
  }
}
