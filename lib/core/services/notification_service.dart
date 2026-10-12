abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> subscribeToTopic(String topic);
}

class NotificationServiceImpl implements NotificationService {
  @override
  Future<void> initialize() async {
    // Initialize FCM / Local Notifications
  }

  @override
  Future<String?> getToken() async {
    return null;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {}
}
