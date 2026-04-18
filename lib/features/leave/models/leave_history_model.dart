import 'package:aims_timekeeper/utils/strings.dart';
import 'package:intl/intl.dart';

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class LeaveHistoryItem {
  final int? leaveApplicationId;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;
  final String reason;
  final DateTime appliedOn;

  const LeaveHistoryItem({
    this.leaveApplicationId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.reason,
    required this.appliedOn,
  });

  factory LeaveHistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value is String && value.isNotEmpty) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return fallback ?? DateTime.now();
    }

    final fromDate = parseDate(
      json['fromDate'] ?? json['startDate'] ?? json['leaveFrom'],
    );
    final toDate = parseDate(
      json['toDate'] ?? json['endDate'] ?? json['leaveTo'],
      fallback: fromDate,
    );
    final appliedOn = parseDate(
      json['appliedOn'] ?? json['createdAt'] ?? json['applicationDate'],
      fallback: fromDate,
    );

    return LeaveHistoryItem(
      leaveApplicationId:
          json['leaveApplicationId'] as int? ??
          json['id'] as int? ??
          json['leaveId'] as int?,
      leaveType:
          (json['leaveTypeName'] ??
                  json['leaveType'] ??
                  json['leaveTypeText'] ??
                  json['name'] ??
                  '')
              .toString(),
      fromDate: fromDate,
      toDate: toDate,
      status:
          (json['status'] ?? json['leaveStatus'] ?? AppStrings.pending)
              .toString(),
      reason: (json['reason'] ?? json['remarks'] ?? '').toString(),
      appliedOn: appliedOn,
    );
  }

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
