import 'package:aims_timekeeper/utils/strings.dart';
import 'leave_history_model.dart';
import 'leave_type_model.dart';

class LeaveModel {
  final bool isApplyTabSelected;
  final bool isSubmitting;
  final bool isLoadingLeaveTypes;
  final bool isLoadingHistory;
  final List<LeaveTypeItem> leaveTypes;
  final LeaveTypeItem? selectedLeaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String selectedSession;
  final String reason;
  final String selectedFilter;
  final List<LeaveHistoryItem> historyItems;
  final String? errorMessage;
  final String? successMessage;

  LeaveModel({
    this.isApplyTabSelected = true,
    this.isSubmitting = false,
    this.isLoadingLeaveTypes = false,
    this.isLoadingHistory = false,
    this.leaveTypes = const [],
    this.selectedLeaveType,
    DateTime? fromDate,
    DateTime? toDate,
    this.selectedSession = AppStrings.fullDay,
    this.reason = '',
    this.selectedFilter = AppStrings.all,
    List<LeaveHistoryItem>? historyItems,
    this.errorMessage,
    this.successMessage,
  }) : fromDate = _normalizeDate(fromDate ?? DateTime.now()),
       toDate = _normalizeDate(
         toDate ?? DateTime.now().add(const Duration(days: 1)),
       ),
       historyItems = historyItems ?? const [];

  LeaveModel copyWith({
    bool? isApplyTabSelected,
    bool? isSubmitting,
    bool? isLoadingLeaveTypes,
    bool? isLoadingHistory,
    List<LeaveTypeItem>? leaveTypes,
    LeaveTypeItem? selectedLeaveType,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedSession,
    String? reason,
    String? selectedFilter,
    List<LeaveHistoryItem>? historyItems,
    String? errorMessage,
    String? successMessage,
  }) {
    return LeaveModel(
      isApplyTabSelected: isApplyTabSelected ?? this.isApplyTabSelected,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingLeaveTypes: isLoadingLeaveTypes ?? this.isLoadingLeaveTypes,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      selectedLeaveType: selectedLeaveType ?? this.selectedLeaveType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedSession: selectedSession ?? this.selectedSession,
      reason: reason ?? this.reason,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      historyItems: historyItems ?? this.historyItems,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int get totalDays => toDate.difference(fromDate).inDays + 1;

  String get durationText {
    final suffix =
        totalDays == 1 ? AppStrings.daySuffix : AppStrings.daysSuffix;
    return '$totalDays $suffix';
  }

  List<LeaveHistoryItem> get filteredHistoryItems {
    if (selectedFilter == AppStrings.all) return historyItems;

    return historyItems.where((item) => item.status == selectedFilter).toList();
  }
}
