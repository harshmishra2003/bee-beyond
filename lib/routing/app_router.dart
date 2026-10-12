import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/courses/presentation/screens/course_detail_screen.dart';
import '../features/courses/presentation/screens/course_enrollment_screen.dart';
import '../features/courses/presentation/screens/enrollment_receipt_screen.dart';
import '../features/courses/presentation/screens/course_material_screen.dart';
import '../features/courses/presentation/screens/courses_list_screen.dart';
import '../features/courses/presentation/screens/joined_courses_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/library/presentation/screens/material_screen.dart';
import '../features/library/presentation/screens/music_screen.dart';
import '../features/library/presentation/screens/video_screen.dart';
import '../features/main_layout/presentation/screens/main_screen.dart';
import '../features/membership/presentation/screens/membership_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/orders/presentation/screens/orders_list_screen.dart';
import '../features/orders/presentation/screens/receipts_list_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/products/presentation/screens/products_list_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/services/presentation/screens/services_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../features/settings/presentation/screens/support_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: RouteNames.otp,
        builder: (context, state) => const OtpScreen(),
      ),

      // StatefulShellRoute for Bottom Navigation Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.courses,
                name: RouteNames.courses,
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return CoursesListScreen(initialCategory: category);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cart,
                name: RouteNames.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        path: RoutePaths.courseDetail,
        name: RouteNames.courseDetail,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'c_1';
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.courseEnrollment,
        name: RouteNames.courseEnrollment,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'c_1';
          return CourseEnrollmentScreen(courseId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.enrollmentReceipt,
        name: RouteNames.enrollmentReceipt,
        builder: (context, state) {
          final data = (state.extra as Map<String, dynamic>?) ?? {};
          return EnrollmentReceiptScreen(data: data);
        },
      ),
      GoRoute(
        path: RoutePaths.joinedCourses,
        name: RouteNames.joinedCourses,
        builder: (context, state) => const JoinedCoursesScreen(),
      ),
      GoRoute(
        path: RoutePaths.courseMaterial,
        name: RouteNames.courseMaterial,
        builder: (context, state) => const CourseMaterialScreen(),
      ),

      GoRoute(
        path: RoutePaths.products,
        name: RouteNames.products,
        builder: (context, state) => const ProductsListScreen(),
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'p_1';
          return ProductDetailScreen(productId: id);
        },
      ),

      GoRoute(
        path: RoutePaths.checkout,
        name: RouteNames.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RoutePaths.orders,
        name: RouteNames.orders,
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: RoutePaths.receipts,
        name: RouteNames.receipts,
        builder: (context, state) => const ReceiptsListScreen(),
      ),
      GoRoute(
        path: RoutePaths.orderDetail,
        name: RouteNames.orderDetail,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'ORD-998241';
          return OrderDetailScreen(orderId: id);
        },
      ),

      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.membership,
        name: RouteNames.membership,
        builder: (context, state) => const MembershipScreen(),
      ),
      GoRoute(
        path: RoutePaths.services,
        name: RouteNames.services,
        builder: (context, state) => const ServicesScreen(),
      ),

      // Library
      GoRoute(
        path: RoutePaths.library,
        name: RouteNames.library,
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: RoutePaths.music,
        name: RouteNames.music,
        builder: (context, state) => const MusicScreen(),
      ),
      GoRoute(
        path: RoutePaths.video,
        name: 'video',
        builder: (context, state) => const VideoScreen(),
      ),
      GoRoute(
        path: RoutePaths.material,
        name: 'material',
        builder: (context, state) => const MaterialScreen(),
      ),

      // Settings & Profile Edit
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RoutePaths.support,
        name: RouteNames.support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: RoutePaths.privacyPolicy,
        name: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}
