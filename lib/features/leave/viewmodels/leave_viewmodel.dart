import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/leave_repository.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../models/leave_history_model.dart';
import '../models/leave_model.dart';
import '../models/leave_type_model.dart';

class LeaveViewModel extends GetxController {
  final LeaveRepository _leaveRepository = Get.find<LeaveRepository>();
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

    leaveState.value = leaveState.value.copyWith(isSubmitting: true);

    await Future.delayed(const Duration(milliseconds: 600));

    final currentState = leaveState.value;
    final newHistory = [
      LeaveHistoryItem(
        leaveType: currentState.selectedLeaveType!.name,
        fromDate: currentState.fromDate,
        toDate: currentState.toDate,
        status: AppStrings.pending,
        reason: currentState.reason.trim(),
        appliedOn: DateTime.now(),
      ),
      ...currentState.historyItems,
    ];

    reasonController.clear();

    leaveState.value = currentState.copyWith(
      isSubmitting: false,
      isApplyTabSelected: false,
      selectedSession: AppStrings.fullDay,
      selectedFilter: AppStrings.all,
      historyItems: newHistory,
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
