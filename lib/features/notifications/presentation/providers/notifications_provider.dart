import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/app_notification_manager.dart';
import '../../../../core/services/expiry_manager_service.dart';
import '../../../membership/presentation/providers/expiry_provider.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // 'courses', 'orders', 'promos', 'vip_pass', 'greetings'
  final String group; // 'Today', 'Yesterday', 'Earlier'
  bool isUnread;
  bool isExpanded;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    required this.group,
    this.isUnread = true,
    this.isExpanded = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    String? category,
    String? group,
    bool? isUnread,
    bool? isExpanded,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      category: category ?? this.category,
      group: group ?? this.group,
      isUnread: isUnread ?? this.isUnread,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'category': category,
      'group': group,
      'isUnread': isUnread,
      'isExpanded': isExpanded,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      time: json['time']?.toString() ?? 'Just now',
      category: json['category']?.toString() ?? 'greetings',
      group: json['group']?.toString() ?? 'Today',
      isUnread: json['isUnread'] == true,
      isExpanded: json['isExpanded'] == true,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  static const String _storageKey = 'bee_user_notifications_v2';

  NotificationsNotifier() : super([]) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
        return;
      }
    } catch (_) {}

    // Default professional initial marketing & greeting notifications
    final initialList = [
      NotificationItem(
        id: 'n_greet_1',
        title: '🌅 Good Morning, Wellness Seeker!',
        message: 'Start your day with 10 mins of Prana Breathing & Chakra Frequencies for holistic alignment.',
        time: 'Just now',
        category: 'greetings',
        group: 'Today',
        isUnread: true,
      ),
      NotificationItem(
        id: 'n_promo_1',
        title: '🔥 Flash Sale Alert: 95% OFF Remedies',
        message: 'Certified Ayurvedic Upchar & Bach Flower Formulas price dropped to ₹100. Limited stock available!',
        time: '1 hour ago',
        category: 'promos',
        group: 'Today',
        isUnread: true,
      ),
      NotificationItem(
        id: 'n_vip_1',
        title: '⭐ VIP Membership Pass Active',
        message: 'Your Gold VIP Access Pass is active. Enjoy 100% free webinars, ebooks & practitioner guidance.',
        time: 'Yesterday, 04:30 PM',
        category: 'vip_pass',
        group: 'Yesterday',
        isUnread: false,
      ),
      NotificationItem(
        id: 'n_course_1',
        title: '🎓 Course Enrollment Confirmed',
        message: 'Welcome to Certified Ayurvedic Upchar & Prakriti Analysis! Access your study handbook now.',
        time: '2 days ago',
        category: 'courses',
        group: 'Earlier',
        isUnread: false,
      ),
    ];

    state = initialList;
    _saveToStorage(initialList);
  }

  Future<void> _saveToStorage(List<NotificationItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(list.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  /// Post a new notification in-app AND trigger native system tray popup alert
  Future<void> postNotification({
    required String title,
    required String message,
    required String category,
    bool showSystemTray = true,
  }) async {
    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      time: DateFormat('hh:mm a').format(DateTime.now()),
      category: category,
      group: 'Today',
      isUnread: true,
    );

    final updated = [newItem, ...state];
    state = updated;
    _saveToStorage(updated);

    if (showSystemTray) {
      await AppNotificationManager.showSystemTrayNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: message,
      );
    }
  }

  /// Post live course enrollment confirmation notification
  Future<void> postLiveCourseEnrollmentNotification({
    required String courseTitle,
    required String batchDates,
    required String studentName,
  }) async {
    final title = '🌟 Live Batch Enrollment Confirmed!';
    final greetingName = studentName.trim().isNotEmpty ? studentName.trim() : 'Valued Student';
    final message = 'Greetings $greetingName! You are successfully registered for "$courseTitle" ($batchDates). Your live meeting access details are ready in course portal.';
    await postNotification(
      title: title,
      message: message,
      category: 'courses',
      showSystemTray: true,
    );
  }

  /// Post time-based greeting notification with User's Full Name
  Future<void> postTimeBasedGreeting(String userName) async {
    final greeting = AppNotificationManager.getTimeBasedGreeting(userName);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final alreadyPosted = state.any((n) =>
        n.category == 'greetings' &&
        n.title == greeting['title'] &&
        n.time.contains(todayKey));

    if (!alreadyPosted) {
      await postNotification(
        title: greeting['title']!,
        message: greeting['message']!,
        category: 'greetings',
        showSystemTray: true,
      );
    }
  }

  /// Check active pass expiration & trigger dynamic expiry alert notification
  Future<void> checkPassExpiryAlert(
      UserPassSubscription? activePass, String userName) async {
    if (activePass == null) return;

    final name = userName.trim().isNotEmpty ? userName.trim() : 'Dear Member';
    final daysLeft =
        ExpiryManagerService.calculateDaysRemaining(activePass.expiresAt);
    final expiryDateStr =
        DateFormat('dd MMM yyyy').format(activePass.expiresAt);

    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final alreadyPostedToday = state.any((n) =>
        n.id.contains('expiry_${activePass.passId}_$todayKey') ||
        (n.category == 'vip_pass' && n.message.contains(expiryDateStr)));

    if (alreadyPostedToday) return;

    if (activePass.isExpiringSoon && daysLeft >= 0) {
      final daysText = daysLeft == 0
          ? 'today'
          : (daysLeft == 1 ? 'tomorrow' : 'in $daysLeft days');

      await postNotification(
        title: '⚠️ VIP Pass Expiry Alert, $name!',
        message:
            'Your ${activePass.passName} expires $daysText (on $expiryDateStr). Tap to renew now and retain your VIP discounts & access!',
        category: 'vip_pass',
        showSystemTray: true,
      );
    } else if (activePass.isExpired) {
      await postNotification(
        title: '🔴 VIP Pass Expired, $name!',
        message:
            'Your ${activePass.passName} expired on $expiryDateStr. Tap to reactivate your membership pass and restore full access!',
        category: 'vip_pass',
        showSystemTray: true,
      );
    }
  }

  void markAllAsRead() {
    final updated = state.map((n) => n.copyWith(isUnread: false)).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void clearAll() {
    state = [];
    _saveToStorage([]);
  }

  void restoreBackup(List<NotificationItem> backup) {
    state = backup;
    _saveToStorage(backup);
  }

  void removeNotification(String id) {
    final updated = state.where((n) => n.id != id).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void toggleExpandAndRead(String id) {
    final updated = state.map((n) {
      if (n.id == id) {
        return n.copyWith(
          isExpanded: !n.isExpanded,
          isUnread: false,
        );
      }
      return n;
    }).toList();
    state = updated;
    _saveToStorage(updated);
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => n.isUnread).length;
});
