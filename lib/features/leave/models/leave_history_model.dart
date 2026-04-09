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
