abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
  Future<void> setUserId(String userId);
  Future<void> setCurrentScreen(String screenName);
}

class AnalyticsServiceImpl implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // Integrate Firebase Analytics or Mixpanel here
  }

  @override
  Future<void> setUserId(String userId) async {
    // Set user id for analytics
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    // Set current screen
  }
}
