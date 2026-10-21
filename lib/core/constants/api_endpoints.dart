class ApiEndpoints {
  static const String baseUrl = 'https://metricstestingapp.xyz/api';

  // Auth
  static const String login = '/auth/login.php';
  static const String register = '/auth/register.php';
  static const String verifyOtp = '/auth/verify-otp.php';
  static const String forgotPassword = '/auth/forgot_password.php';

  // Home & Dashboard
  static const String homeData = '/home';
  static const String categories = '/categories';
  static const String banners = '/banners';

  // Courses APIs
  static const String courses = '/courses.php';
  static const String courseDetail = '/course_details.php';
  static const String joinedCourses = '/courses/joined';

  // Library & Media
  static const String library = '/library';
  static const String books = '/library/books';
  static const String music = '/music.php';
  static const String video = '/videos.php';

  // Services & Membership
  static const String services = '/services.php';
  static const String membershipPlans = '/membership.php';

  // Products
  static const String products = '/products';
  static const String productDetail = '/products/';

  // Cart & Orders
  static const String cart = '/cart';
  static const String orders = '/orders.php';
  static const String checkout = '/checkout';

  // Profile
  static const String profile = '/user/profile';
  static const String changePassword = '/user/change-password';

  // Notifications
  static const String notifications = '/notifications';
}
