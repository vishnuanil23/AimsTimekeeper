import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/leave_repository.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../models/leave_history_model.dart';
import '../models/leave_model.dart';
import '../models/leave_type_model.dart';

class LeaveViewModel extends GetxController {
  final LeaveRepository _leaveRepository = Get.find<LeaveRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final reasonController = TextEditingController();

  final Rx<LeaveModel> leaveState = LeaveModel().obs;

  List<String> get filterOptions => const [
    AppStrings.all,
    AppStrings.pending,
    AppStrings.approved,
    AppStrings.rejected,
  ];

  List<String> get sessionOptions => const [
    AppStrings.fullDay,
    AppStrings.firstHalf,
    AppStrings.secondHalf,
  ];

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    _loadLeaveTypes();
    _loadLeaveHistory();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    reasonController.addListener(() {
      leaveState.value = leaveState.value.copyWith(
        reason: reasonController.text,
      );
    });
  }

  void selectTab(bool isApplyTabSelected) {
    leaveState.value = leaveState.value.copyWith(
      isApplyTabSelected: isApplyTabSelected,
    );
  }

  void selectLeaveType(LeaveTypeItem? value) {
    if (value == null) return;
    leaveState.value = leaveState.value.copyWith(selectedLeaveType: value);
  }

  Future<void> _loadLeaveTypes() async {
    leaveState.value = leaveState.value.copyWith(isLoadingLeaveTypes: true);

    try {
      final response = await _leaveRepository.getLeaveTypes();

      if (!response.success) {
        _showSnackbar(
          AppStrings.error,
          response.message ?? AppStrings.somethingWentWrong,
          AppColors.error,
          Icons.error_outline_rounded,
        );
        leaveState.value = leaveState.value.copyWith(
          isLoadingLeaveTypes: false,
        );
        return;
      }

      final leaveTypes = _extractLeaveTypes(response.data);
      final selectedLeaveType = leaveTypes.isNotEmpty ? leaveTypes.first : null;

      leaveState.value = leaveState.value.copyWith(
        isLoadingLeaveTypes: false,
        leaveTypes: leaveTypes,
        selectedLeaveType: selectedLeaveType,
      );
    } catch (_) {
      leaveState.value = leaveState.value.copyWith(isLoadingLeaveTypes: false);
      _showSnackbar(
        AppStrings.error,
        AppStrings.somethingWentWrong,
        AppColors.error,
        Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _loadLeaveHistory() async {
    final user = await _storageService.getUser();
    final int? employeeId = _resolveEmployeeId(user);

    if (employeeId == null) {
      leaveState.value = leaveState.value.copyWith(historyItems: const []);
      return;
    }

    leaveState.value = leaveState.value.copyWith(isLoadingHistory: true);

    try {
      final response = await _leaveRepository.getLeaveHistory(
        employeeId: employeeId,
      );

      if (!response.success) {
        leaveState.value = leaveState.value.copyWith(isLoadingHistory: false);
        _showSnackbar(
          AppStrings.error,
          response.message ?? AppStrings.somethingWentWrong,
          AppColors.error,
          Icons.history_toggle_off_rounded,
        );
        return;
      }

      final historyItems = _extractLeaveHistory(response.data);

      leaveState.value = leaveState.value.copyWith(
        isLoadingHistory: false,
        historyItems: historyItems,
      );
    } catch (_) {
      leaveState.value = leaveState.value.copyWith(isLoadingHistory: false);
      _showSnackbar(
        AppStrings.error,
        AppStrings.somethingWentWrong,
        AppColors.error,
        Icons.history_toggle_off_rounded,
      );
    }
  }

  List<LeaveTypeItem> _extractLeaveTypes(dynamic data) {
    dynamic rawList = data;

    if (rawList is Map<String, dynamic>) {
      rawList = rawList['data'] ?? rawList['items'] ?? rawList['leaveTypes'];
    }

    if (rawList is! List) return [];

    return rawList
        .map((item) {
          if (item is Map<String, dynamic>) {
            final leaveTypeId = item['leaveTypeId'];
            final name = item['name'];

            if (leaveTypeId is int && name != null) {
              return LeaveTypeItem.fromJson(item);
            }
          }
          return null;
        })
        .whereType<LeaveTypeItem>()
        .toList();
  }

  List<LeaveHistoryItem> _extractLeaveHistory(dynamic data) {
    dynamic rawList = data;

    if (rawList is Map<String, dynamic>) {
      rawList = rawList['data'] ?? rawList['items'] ?? rawList['history'];
    }

    if (rawList is! List) return [];

    return rawList
        .map((item) {
          if (item is Map<String, dynamic>) {
            return LeaveHistoryItem.fromJson(item);
          }
          return null;
        })
        .whereType<LeaveHistoryItem>()
        .toList();
  }

  void selectSession(String session) {
    leaveState.value = leaveState.value.copyWith(selectedSession: session);
  }

  void selectFilter(String filter) {
    leaveState.value = leaveState.value.copyWith(selectedFilter: filter);
  }

  Future<void> pickFromDate(BuildContext context) async {
    final selectedDate = await _pickDate(
      context,
      initialDate: leaveState.value.fromDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    final adjustedToDate =
        selectedDate.isAfter(leaveState.value.toDate)
            ? selectedDate
            : leaveState.value.toDate;

    leaveState.value = leaveState.value.copyWith(
      fromDate: selectedDate,
      toDate: adjustedToDate,
    );
  }

  Future<void> pickToDate(BuildContext context) async {
    final selectedDate = await _pickDate(
      context,
      initialDate: leaveState.value.toDate,
      firstDate: leaveState.value.fromDate,
    );

    if (selectedDate == null) return;

    leaveState.value = leaveState.value.copyWith(toDate: selectedDate);
  }

  Future<DateTime?> _pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> submitLeaveApplication() async {
    if (!_validateForm()) return;

    final currentState = leaveState.value;
    final user = await _storageService.getUser();
    final int? employeeId = _resolveEmployeeId(user);

    if (employeeId == null) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.userIdMissing,
        AppColors.error,
        Icons.person_off_rounded,
      );
      return;
    }

    leaveState.value = currentState.copyWith(isSubmitting: true);

    final response = await _leaveRepository.applyLeave(
      employeeId: employeeId,
      leaveTypeId: currentState.selectedLeaveType!.leaveTypeId,
      fromDate: _startOfDay(currentState.fromDate),
      toDate: _endOfDay(currentState.toDate),
      leaveSessionDuration: _mapSessionDuration(currentState.selectedSession),
      reason: currentState.reason.trim(),
    );

    if (!response.success) {
      leaveState.value = currentState.copyWith(isSubmitting: false);
      _showSnackbar(
        AppStrings.error,
        response.message ?? AppStrings.somethingWentWrong,
        AppColors.error,
        Icons.error_outline_rounded,
      );
      return;
    }

    reasonController.clear();

    leaveState.value = currentState.copyWith(
      isSubmitting: false,
      isApplyTabSelected: false,
      selectedSession: AppStrings.fullDay,
      selectedFilter: AppStrings.all,
      reason: '',
      successMessage: AppStrings.leaveAppliedSuccess,
      fromDate: DateTime.now(),
      toDate: DateTime.now().add(const Duration(days: 1)),
    );

    _showSnackbar(
      AppStrings.success,
      AppStrings.leaveAppliedSuccess,
      AppColors.success,
      Icons.check_circle,
    );

    await _loadLeaveHistory();
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int? _resolveEmployeeId(Map<String, dynamic>? user) {
    if (user == null) return null;

    // Attendance uses stored user["id"] as userId, so leave apply should use
    // that same value for employeeID to stay aligned with the backend contract.
    final dynamic rawEmployeeId =
        user['id'] ?? user['employeeID'] ?? user['employeeId'];

    if (rawEmployeeId is int) return rawEmployeeId;
    if (rawEmployeeId is num) return rawEmployeeId.toInt();
    if (rawEmployeeId is String) return int.tryParse(rawEmployeeId);

    return null;
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  String _mapSessionDuration(String session) {
    switch (session) {
      case AppStrings.firstHalf:
        return 'First Half';
      case AppStrings.secondHalf:
        return 'Second Half';
      default:
        return 'Full Day';
    }
  }

  bool _validateForm() {
    final state = leaveState.value;

    if (state.toDate.isBefore(state.fromDate)) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.selectValidDates,
        AppColors.error,
        Icons.event_busy_rounded,
      );
      return false;
    }

    if (state.selectedLeaveType == null) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.leaveTypeRequired,
        AppColors.error,
        Icons.list_alt_rounded,
      );
      return false;
    }

    if (state.reason.trim().isEmpty) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.reasonRequired,
        AppColors.error,
        Icons.error_outline_rounded,
      );
      return false;
    }

    return true;
  }

  void _showSnackbar(
    String title,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: AppColors.white,
      icon: Icon(icon, color: AppColors.white),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
