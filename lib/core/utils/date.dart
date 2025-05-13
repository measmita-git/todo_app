import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  static String timeLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left';
    } else {
      return 'Less than a minute left';
    }
  }

  static bool isExpired(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }

  static Duration timeUntilDeadline(DateTime deadline) {
    final now = DateTime.now();
    return deadline.difference(now);
  }

  static Duration timeUntilOneHourBefore(DateTime deadline) {
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));
    final now = DateTime.now();
    return oneHourBefore.difference(now);
  }

  static bool shouldNotify(DateTime deadline) {
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));
    final now = DateTime.now();

    return now.isAfter(oneHourBefore) && now.isBefore(deadline);
  }
}