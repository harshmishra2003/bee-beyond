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
import 'page_transitions.dart';
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
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const SplashScreen(),
          type: AppTransitionType.fadeScale,
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
          type: AppTransitionType.fadeScale,
        ),
      ),

      // Auth
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const LoginScreen(),
          type: AppTransitionType.fadeScale,
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const RegisterScreen(),
          type: AppTransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: RouteNames.otp,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const OtpScreen(),
          type: AppTransitionType.fadeScale,
        ),
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
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'c_1';
          return buildCustomTransitionPage(
            context: context,
            state: state,
            child: CourseDetailScreen(courseId: id),
            type: AppTransitionType.slideUp,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.courseEnrollment,
        name: RouteNames.courseEnrollment,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'c_1';
          return buildCustomTransitionPage(
            context: context,
            state: state,
            child: CourseEnrollmentScreen(courseId: id),
            type: AppTransitionType.slideUp,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.enrollmentReceipt,
        name: RouteNames.enrollmentReceipt,
        pageBuilder: (context, state) {
          final data = (state.extra as Map<String, dynamic>?) ?? {};
          return buildCustomTransitionPage(
            context: context,
            state: state,
            child: EnrollmentReceiptScreen(data: data),
            type: AppTransitionType.slideUp,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.joinedCourses,
        name: RouteNames.joinedCourses,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const JoinedCoursesScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.courseMaterial,
        name: RouteNames.courseMaterial,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const CourseMaterialScreen(),
          type: AppTransitionType.slideUp,
        ),
      ),

      GoRoute(
        path: RoutePaths.products,
        name: RouteNames.products,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const ProductsListScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'p_1';
          return buildCustomTransitionPage(
            context: context,
            state: state,
            child: ProductDetailScreen(productId: id),
            type: AppTransitionType.slideUp,
          );
        },
      ),

      GoRoute(
        path: RoutePaths.checkout,
        name: RouteNames.checkout,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const CheckoutScreen(),
          type: AppTransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: RoutePaths.orders,
        name: RouteNames.orders,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const OrdersListScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.receipts,
        name: RouteNames.receipts,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const ReceiptsListScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.orderDetail,
        name: RouteNames.orderDetail,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'ORD-998241';
          return buildCustomTransitionPage(
            context: context,
            state: state,
            child: OrderDetailScreen(orderId: id),
            type: AppTransitionType.slideRight,
          );
        },
      ),

      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const NotificationsScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const SearchScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.membership,
        name: RouteNames.membership,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const MembershipScreen(),
          type: AppTransitionType.slideUp,
        ),
      ),
      GoRoute(
        path: RoutePaths.services,
        name: RouteNames.services,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const ServicesScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),

      // Library
      GoRoute(
        path: RoutePaths.library,
        name: RouteNames.library,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const LibraryScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.music,
        name: RouteNames.music,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const MusicScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.video,
        name: 'video',
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const VideoScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.material,
        name: 'material',
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const MaterialScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),

      // Settings & Profile Edit
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const EditProfileScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        name: RouteNames.changePassword,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const ChangePasswordScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const AboutScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.support,
        name: RouteNames.support,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const SupportScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: RoutePaths.privacyPolicy,
        name: RouteNames.privacyPolicy,
        pageBuilder: (context, state) => buildCustomTransitionPage(
          context: context,
          state: state,
          child: const PrivacyPolicyScreen(),
          type: AppTransitionType.slideRight,
        ),
      ),
    ],
  );
}
