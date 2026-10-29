import 'package:intl/intl.dart';

enum AccessStatus {
  active,
  expiringSoon,
  gracePeriod,
  expired,
}

class ExpiryManagerService {
  /// Returns the number of days remaining until expiration date
  static int calculateDaysRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    return difference.inDays;
  }

  /// Returns true if current date is past the expiration date
  static bool isPassExpired(DateTime expiresAt) {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Returns true if pass expired within the last [graceDays] days (default 7)
  static bool isInGracePeriod(DateTime expiresAt, {int graceDays = 7}) {
    if (!isPassExpired(expiresAt)) return false;
    final now = DateTime.now();
    final graceDeadline = expiresAt.add(Duration(days: graceDays));
    return now.isBefore(graceDeadline);
  }

  /// Returns true if pass expires within [thresholdDays] days (default 7)
  static bool isExpiringSoon(DateTime expiresAt, {int thresholdDays = 7}) {
    if (isPassExpired(expiresAt)) return false;
    final daysLeft = calculateDaysRemaining(expiresAt);
    return daysLeft >= 0 && daysLeft <= thresholdDays;
  }

  /// Categorizes access status into enum
  static AccessStatus getAccessStatus(DateTime expiresAt) {
    if (isPassExpired(expiresAt)) {
      if (isInGracePeriod(expiresAt)) {
        return AccessStatus.gracePeriod;
      }
      return AccessStatus.expired;
    }
    if (isExpiringSoon(expiresAt)) {
      return AccessStatus.expiringSoon;
    }
    return AccessStatus.active;
  }

  /// Returns human-readable status label
  static String formatExpiryStatus(DateTime expiresAt) {
    final status = getAccessStatus(expiresAt);
    final daysLeft = calculateDaysRemaining(expiresAt);

    switch (status) {
      case AccessStatus.active:
        return '$daysLeft Days Remaining';
      case AccessStatus.expiringSoon:
        if (daysLeft == 0) return 'Expires Today!';
        if (daysLeft == 1) return 'Expires Tomorrow!';
        return 'Expires in $daysLeft Days';
      case AccessStatus.gracePeriod:
        final expiredDays = DateTime.now().difference(expiresAt).inDays;
        return 'Expired $expiredDays Days Ago (Grace Period Active)';
      case AccessStatus.expired:
        final dateStr = DateFormat('dd MMM yyyy').format(expiresAt);
        return 'Expired on $dateStr';
    }
  }

  /// Calculates elapsed duration progress between 0.0 and 1.0
  static double getExpiryProgress(DateTime startDate, DateTime expiresAt) {
    final now = DateTime.now();
    final totalDuration = expiresAt.difference(startDate).inSeconds;
    if (totalDuration <= 0) return 1.0;

    final elapsed = now.difference(startDate).inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }
}
