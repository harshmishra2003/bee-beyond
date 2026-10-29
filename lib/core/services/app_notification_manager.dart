import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotificationManager {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize Android & iOS Native System Tray Notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle native notification click
      },
    );

    _isInitialized = true;
  }

  /// Trigger System Tray Native Notification
  static Future<void> showSystemTrayNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'bee_beeyond_high_priority_v1',
      'Bee Beyonnd Alerts & Updates',
      channelDescription:
          'High priority notifications for course enrollments, order updates, VIP pass alerts, and daily wellness greetings.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Generate Time-Based Greeting Notification Content with User's Full Name
  static Map<String, String> getTimeBasedGreeting(String userName) {
    final hour = DateTime.now().hour;
    final name = userName.trim().isNotEmpty ? userName.trim() : 'Dear Member';

    if (hour >= 5 && hour < 12) {
      return {
        'title': '🌅 Good Morning, $name!',
        'message':
            'Start your morning with 10 mins of Prana Breathing & Chakra Frequencies for alignment.',
      };
    } else if (hour >= 12 && hour < 17) {
      return {
        'title': '☀️ Afternoon Rejuvenation, $name!',
        'message':
            'Time for a quick Ayurvedic Mind Balance audio session to boost focus & energy.',
      };
    } else if (hour >= 17 && hour < 21) {
      return {
        'title': '🌆 Evening Tranquility, $name!',
        'message':
            'Unwind your day with soothing Bach Remedy music & peaceful meditation.',
      };
    } else {
      return {
        'title': '🌙 Peaceful Night Sleep, $name!',
        'message':
            'Listen to 432 Hz Binaural Sleep Audio for deep restorative rest.',
      };
    }
  }
}
