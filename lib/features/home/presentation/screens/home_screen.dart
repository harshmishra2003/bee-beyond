import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/expiry_alert_banner.dart';
import '../../../../core/widgets/shining_view_all_button.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/managers/cart_manager.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../membership/presentation/providers/expiry_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/category_carousel.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_drawer.dart';
import '../widgets/joined_courses_section.dart';
import '../widgets/kpi_action_grid.dart';
import '../widgets/our_courses_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _searchHintTimer;
  int _currentHintIndex = 0;

  static const List<String> _searchHints = [
    'Search "Certified Courses"...',
    'Search "Bach Flower Remedies"...',
    'Search "Vastu Shastra Consultation"...',
    'Search "Ayurvedic Lifestyle"...',
    'Search "Mind & Life Coaching"...',
    'Search "Healing Oils & Products"...',
    'Search "Library & Study Materials"...',
    'Search "Personalized Services"...',
  ];

  @override
  void initState() {
    super.initState();
    _searchHintTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentUser = ref.read(authStateProvider).user;
        final fullName = currentUser?.name.trim().isNotEmpty == true
            ? currentUser!.name.trim()
            : 'Dear Member';

        // 1. Post Time-Based Greeting Notification with Full Name
        ref.read(notificationsProvider.notifier).postTimeBasedGreeting(fullName);

        // 2. Check VIP Membership Pass Expiry & Trigger Dynamic Alert
        final activePass = ref.read(activePassProvider);
        ref.read(notificationsProvider.notifier).checkPassExpiryAlert(activePass, fullName);
      }
    });
  }

  @override
  void dispose() {
    _searchHintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    
    // Dynamic Cart Items Count
    final cartAsync = ref.watch(cartManagerProvider);
    final cartItemCount = cartAsync.value?.totalItems ?? 0;

    // Dynamic Unread Notifications Count
    final unreadNotificationCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 24),
            ),
          ),
        ),
        title: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Image.asset(
                AssetPaths.beeBeyondImage1,
                height: 38,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.spa_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      'Bee Beeyond',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          // DYNAMICALLY STYLED CART ACTION WITH GREEN ICON & BADGE
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 6.0),
            child: InkWell(
              onTap: () => context.go(RoutePaths.cart),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1010B981),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_rounded, color: Color(0xFF059669), size: 21),
                    if (cartItemCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF312E81),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                          child: Text(
                            '$cartItemCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // DYNAMICALLY STYLED NOTIFICATION BELL ACTION WITH AMBER ICON & BADGE
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 10.0),
            child: InkWell(
              onTap: () => context.push(RoutePaths.notifications),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10F59E0B),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded, color: Color(0xFFD97706), size: 21),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                          child: Text(
                            '$unreadNotificationCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: homeDataAsync.when(
        skipLoadingOnRefresh: true,
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(allCoursesProvider);
            ref.invalidate(homeDataProvider);
            ref.invalidate(joinedCoursesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 14),

              // Search Console Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => context.push(RoutePaths.search),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary, width: 1.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C4B489B),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.4),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: Align(
                              key: ValueKey<int>(_currentHintIndex),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _searchHints[_currentHintIndex],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // EXPIRY ALERT BANNER OVERLAY
              const ExpiryAlertBanner(),

              const SizedBox(height: 8),

              // KPI Action Buttons Grid surrounded by Single Multicolour Combination Frame
              KPIActionGrid(
                onItemTap: (route) {
                  context.push(route);
                },
              ),
              const SizedBox(height: 16),

              // Auto-Scrolling Circular Categories Section with Header & Shining View All Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore Categories',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ShiningViewAllButton(
                      onPressed: () => context.go(RoutePaths.courses),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CategoryCarousel(
                categories: data.categories,
                onCategorySelected: (cat) {
                  context.go('${RoutePaths.courses}?category=${Uri.encodeComponent(cat.name)}');
                },
              ),
              const SizedBox(height: 18),

              // Auto-Scrolling Banners & Posters Section with Header & Shining View All Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Posters & Offers',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ShiningViewAllButton(
                      onPressed: () => context.go(RoutePaths.courses),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              HomeBannerSlider(
                banners: data.banners,
                onBannerTap: (banner) {
                  context.go(RoutePaths.courses);
                },
              ),
              const SizedBox(height: 22),

              // JOINED COURSE Section with Purple Header & Shining View All Button
              JoinedCoursesSection(
                onViewAllTap: () => context.go(RoutePaths.courses),
                onLearnTap: (courseId) => context.push('${RoutePaths.courseDetail}?id=$courseId'),
                onJoinGroupTap: (courseId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Joined WhatsApp Study Group Successfully!')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // OUR COURSES Section with Purple Header & Shining View All Button
              OurCoursesSection(
                onViewAllTap: () => context.go(RoutePaths.courses),
                onCourseTap: (courseId) => context.push('${RoutePaths.courseDetail}?id=$courseId'),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading home data: $err'),
          ),
        ),
      ),
    );
  }
}
