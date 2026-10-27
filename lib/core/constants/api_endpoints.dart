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
  static const String books = '/books.php';
  static const String bookDetail = '/book_details.php';
  static const String music = '/music.php';
  static const String video = '/videos.php';

  // Services & Membership
  static const String services = '/services.php';
  static const String membershipPlans = '/membership.php';
  static const String membershipPlanDetails = '/membership_plan_details.php';

  // Products
  static const String products = '/products.php';
  static const String productDetail = '/product_details.php';

  // Cart & Orders
  static const String cart = '/cart';
  static const String orders = '/orders.php';
  static const String checkout = '/checkout';
  static const String createOrder = '/checkout/create_order.php';
  static const String verifyPayment = '/checkout/verify-payment.php';

  // Profile
  static const String profile = '/user/profile';
  static const String changePassword = '/user/change-password';

  // Notifications
  static const String notifications = '/notifications';
}
