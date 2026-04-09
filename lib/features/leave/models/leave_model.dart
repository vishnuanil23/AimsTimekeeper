import 'package:aims_timekeeper/utils/strings.dart';
import 'package:intl/intl.dart';

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class LeaveHistoryItem {
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;
  final String reason;
  final DateTime appliedOn;

  const LeaveHistoryItem({
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.reason,
    required this.appliedOn,
  });

  int get dayCount => toDate.difference(fromDate).inDays + 1;

  String get durationText {
    final suffix = dayCount == 1 ? AppStrings.daySuffix : AppStrings.daysSuffix;
    return '$dayCount $suffix';
  }

  String get dateRangeText {
    final formatter = DateFormat('MMM d, yyyy');
    final shortFormatter = DateFormat('MMM d');

    if (_isSameDay(fromDate, toDate)) {
      return formatter.format(fromDate);
    }

    if (fromDate.year == toDate.year) {
      return '${shortFormatter.format(fromDate)} - ${formatter.format(toDate)}';
    }

    return '${formatter.format(fromDate)} - ${formatter.format(toDate)}';
  }
}

class LeaveModel {
  final bool isApplyTabSelected;
  final bool isSubmitting;
  final String selectedLeaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String selectedSession;
  final String contactNumber;
  final String reason;
  final String selectedFilter;
  final String? attachmentName;
  final List<LeaveHistoryItem> historyItems;
  final String? errorMessage;
  final String? successMessage;

  LeaveModel({
    this.isApplyTabSelected = true,
    this.isSubmitting = false,
    this.selectedLeaveType = AppStrings.annualLeave,
    DateTime? fromDate,
    DateTime? toDate,
    this.selectedSession = AppStrings.fullDay,
    this.contactNumber = '',
    this.reason = '',
    this.selectedFilter = AppStrings.all,
    this.attachmentName,
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
    String? selectedLeaveType,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedSession,
    String? contactNumber,
    String? reason,
    String? selectedFilter,
    String? attachmentName,
    List<LeaveHistoryItem>? historyItems,
    String? errorMessage,
    String? successMessage,
  }) {
    return LeaveModel(
      isApplyTabSelected: isApplyTabSelected ?? this.isApplyTabSelected,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedLeaveType: selectedLeaveType ?? this.selectedLeaveType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedSession: selectedSession ?? this.selectedSession,
      contactNumber: contactNumber ?? this.contactNumber,
      reason: reason ?? this.reason,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      attachmentName: attachmentName ?? this.attachmentName,
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
        leaveType: AppStrings.annualLeave,
        fromDate: DateTime(2026, 4, 10),
        toDate: DateTime(2026, 4, 11),
        status: AppStrings.pending,
        reason: 'Family function',
        appliedOn: DateTime(2026, 4, 9),
      ),
      LeaveHistoryItem(
        leaveType: AppStrings.sickLeave,
        fromDate: DateTime(2026, 3, 20),
        toDate: DateTime(2026, 3, 21),
        status: AppStrings.approved,
        reason: 'Fever and cold',
        appliedOn: DateTime(2026, 3, 19),
      ),
      LeaveHistoryItem(
        leaveType: AppStrings.casualLeave,
        fromDate: DateTime(2026, 2, 14),
        toDate: DateTime(2026, 2, 14),
        status: AppStrings.rejected,
        reason: 'Personal work',
        appliedOn: DateTime(2026, 2, 12),
      ),
      LeaveHistoryItem(
        leaveType: AppStrings.annualLeave,
        fromDate: DateTime(2026, 1, 26),
        toDate: DateTime(2026, 1, 28),
        status: AppStrings.approved,
        reason: 'Republic Day holidays',
        appliedOn: DateTime(2026, 1, 20),
      ),
    ];
  }
}
