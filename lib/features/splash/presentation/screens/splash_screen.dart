import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final AnimationController _loadingController;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _introController.forward();

    // Auto-navigate after 3.8 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    final authState = ref.read(authStateProvider);
    if (authState.status == AuthStatus.authenticated) {
      context.go(RoutePaths.home);
    } else if (!authState.hasSeenOnboarding) {
      context.go(RoutePaths.onboarding);
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _floatController,
          _glowController,
          _loadingController,
        ]),
        builder: (context, child) {
          final entrance = Curves.easeOutCubic.transform(
            _introController.value,
          );

          final floating = math.sin(_floatController.value * math.pi) * 8.0;
          final glow = 0.15 + (_glowController.value * 0.15);

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF9F5FF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFF0F7),
                  Color(0xFFF0ECFF),
                ],
                stops: [0.0, 0.38, 0.72, 1.0],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Soft ambient background glows
                Positioned(
                  top: -100,
                  right: -90,
                  child: _orb(270, const Color(0xFFD9C4FF), glow),
                ),
                Positioned(
                  bottom: -110,
                  left: -100,
                  child: _orb(300, const Color(0xFFFFC8E5), glow),
                ),
                Positioned(
                  top: 180,
                  left: -70,
                  child: _orb(140, const Color(0xFFE9D9FF), glow),
                ),

                // Main brand splash content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Opacity(
                        opacity: entrance.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - entrance)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Hero Splash Card Artwork
                              Transform.translate(
                                offset: Offset(0, -floating),
                                child: Transform.scale(
                                  scale: 0.85 + (0.15 * entrance),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF8D5DE8)
                                              .withValues(alpha: glow),
                                          blurRadius: 48,
                                          spreadRadius: 8,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.asset(
                                        AssetPaths.splashScreenImage,
                                        width: MediaQuery.of(context).size.width * 0.88,
                                        height: MediaQuery.of(context).size.height * 0.46,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            AssetPaths.beeBeyondImage1,
                                            width: 280,
                                            height: 180,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Brand Headers
                              Text(
                                'YOUR WELLNESS,',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  letterSpacing: 4.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7951B6),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Your Journey Begins Here',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  height: 1.25,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                  color: const Color(0xFF392064),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                'Steps towards physical and mental wellbeing',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  height: 1.5,
                                  letterSpacing: 0.3,
                                  color: const Color(0xFF756987),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Animated Loading Progress Bar
                              SizedBox(
                                width: 110,
                                height: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: _loadingController.value,
                                    backgroundColor: const Color(0xFFE9DDFB),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF8246D8),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                'PREPARING YOUR EXPERIENCE',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  letterSpacing: 2.2,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9584AE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _orb(double size, Color color, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
