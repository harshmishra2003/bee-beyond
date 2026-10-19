import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/onboarding_page_four.dart';
import '../widgets/onboarding_page_one.dart';
import '../widgets/onboarding_page_three.dart';
import '../widgets/onboarding_page_two.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _leavesController;

  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _leavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _leavesController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(authStateProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Clean Elegant Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFAF9FE),
                    Color(0xFFFFFFFF),
                    Color(0xFFF2F0FC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Floating Leaves Animation Overlay
          AnimatedBuilder(
            animation: _leavesController,
            builder: (context, child) {
              final t = _leavesController.value;
              final swayAngle = math.sin(t * math.pi * 2) * 0.05;
              final swayY = math.cos(t * math.pi * 2) * 5.0;
              final vibrationX = math.sin(t * math.pi * 6) * 1.8;

              return Stack(
                children: [
                  Positioned(
                    top: -5 + swayY,
                    left: -5 + vibrationX,
                    child: Transform.rotate(
                      angle: swayAngle,
                      child: _buildLeafShape(width: 120, height: 120, color: AppColors.primary.withValues(alpha: 0.18)),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.08 - swayY,
                    right: 15 + vibrationX,
                    child: Transform.rotate(
                      angle: -swayAngle * 1.4,
                      child: _buildLeafShape(width: 45, height: 45, color: AppColors.primaryLight.withValues(alpha: 0.25)),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main Page Content & Control Bar
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar: SKIP Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: const [
                      OnboardingPageOne(),
                      OnboardingPageTwo(),
                      OnboardingPageThree(),
                      OnboardingPageFour(),
                    ],
                  ),
                ),

                // Bottom Control Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x184B489B),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bottom Skip Button
                      GestureDetector(
                        onTap: _finishOnboarding,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      // Animated Page Indicator Dots
                      Row(
                        children: List.generate(_totalPages, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: isActive ? 24.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : AppColors.borderSubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Next / Get Started Button
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: AppColors.button3DGradient,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x284B489B),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _onNextPage,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeafShape({required double width, required double height, required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
    );
  }
}
