class DateTimeUtils {
  /// Format time → 7:45 PM
  static String formatTime(DateTime dt) {
    int hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    if (hour == 0) hour = 12;

    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";

    return '$hour:$minute $period';
  }

  /// Format date → 23 Dec 2025
  static String formatDate(DateTime dt) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final monthName = months[dt.month - 1];
    return '${dt.day} $monthName ${dt.year}';
  }

  /// Get time-based greeting
  static String getGreeting(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
