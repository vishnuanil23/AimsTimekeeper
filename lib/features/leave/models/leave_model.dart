import 'package:aims_timekeeper/utils/strings.dart';
import 'leave_history_model.dart';
import 'leave_type_model.dart';

class LeaveModel {
  final bool isApplyTabSelected;
  final bool isSubmitting;
  final bool isLoadingLeaveTypes;
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
       historyItems = historyItems ?? _defaultHistoryItems();

  LeaveModel copyWith({
    bool? isApplyTabSelected,
    bool? isSubmitting,
    bool? isLoadingLeaveTypes,
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

  static List<LeaveHistoryItem> _defaultHistoryItems() {
    return [
      LeaveHistoryItem(
        leaveType: 'Annual Leave',
        fromDate: DateTime(2026, 4, 10),
        toDate: DateTime(2026, 4, 11),
        status: AppStrings.pending,
        reason: 'Family function',
        appliedOn: DateTime(2026, 4, 9),
      ),
      LeaveHistoryItem(
        leaveType: 'Sick Leave',
        fromDate: DateTime(2026, 3, 20),
        toDate: DateTime(2026, 3, 21),
        status: AppStrings.approved,
        reason: 'Fever and cold',
        appliedOn: DateTime(2026, 3, 19),
      ),
      LeaveHistoryItem(
        leaveType: 'Casual Leave',
        fromDate: DateTime(2026, 2, 14),
        toDate: DateTime(2026, 2, 14),
        status: AppStrings.rejected,
        reason: 'Personal work',
        appliedOn: DateTime(2026, 2, 12),
      ),
      LeaveHistoryItem(
        leaveType: 'Annual Leave',
        fromDate: DateTime(2026, 1, 26),
        toDate: DateTime(2026, 1, 28),
        status: AppStrings.approved,
        reason: 'Republic Day holidays',
        appliedOn: DateTime(2026, 1, 20),
      ),
    ];
  }
}
