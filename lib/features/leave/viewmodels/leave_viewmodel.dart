import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../models/leave_model.dart';

class LeaveViewModel extends GetxController {
  final contactController = TextEditingController();
  final reasonController = TextEditingController();

  final Rx<LeaveModel> leaveState = LeaveModel().obs;

  List<String> get leaveTypes => const [
    AppStrings.annualLeave,
    AppStrings.sickLeave,
    AppStrings.casualLeave,
    AppStrings.maternityPaternityLeave,
    AppStrings.emergencyLeave,
    AppStrings.unpaidLeave,
  ];

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
  }

  @override
  void onClose() {
    contactController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    contactController.addListener(() {
      leaveState.value = leaveState.value.copyWith(
        contactNumber: contactController.text,
      );
    });

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

  void selectLeaveType(String? value) {
    if (value == null) return;
    leaveState.value = leaveState.value.copyWith(selectedLeaveType: value);
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

  void uploadAttachmentPlaceholder() {
    _showSnackbar(
      AppStrings.attachment,
      AppStrings.attachmentUploadSoon,
      AppColors.info,
      Icons.attach_file_rounded,
    );
  }

  Future<void> submitLeaveApplication() async {
    if (!_validateForm()) return;

    leaveState.value = leaveState.value.copyWith(isSubmitting: true);

    await Future.delayed(const Duration(milliseconds: 600));

    final currentState = leaveState.value;
    final newHistory = [
      LeaveHistoryItem(
        leaveType: currentState.selectedLeaveType,
        fromDate: currentState.fromDate,
        toDate: currentState.toDate,
        status: AppStrings.pending,
        reason: currentState.reason.trim(),
        appliedOn: DateTime.now(),
      ),
      ...currentState.historyItems,
    ];

    contactController.clear();
    reasonController.clear();

    leaveState.value = currentState.copyWith(
      isSubmitting: false,
      isApplyTabSelected: false,
      selectedSession: AppStrings.fullDay,
      selectedFilter: AppStrings.all,
      attachmentName: null,
      historyItems: newHistory,
      contactNumber: '',
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

    if (state.contactNumber.trim().isEmpty) {
      _showSnackbar(
        AppStrings.error,
        AppStrings.contactRequired,
        AppColors.error,
        Icons.phone_rounded,
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
