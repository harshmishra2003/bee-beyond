import 'dart:async';
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
  late final AnimationController _loadingController;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

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
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _loadingController,
        ]),
        builder: (context, child) {
          final entrance = Curves.easeOutCubic.transform(
            _introController.value,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. FULL-SCREEN EDGE-TO-EDGE SPLASH IMAGE (Fills 100% Mobile & Tablet Screens)
              Opacity(
                opacity: entrance.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1.02 + (0.04 * (1 - entrance)),
                  child: Image.asset(
                    AssetPaths.splashScreenImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AssetPaths.beeBeyondImage1,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),

              // 2. BOTTOM FLOATING ANIMATED PROGRESS INDICATOR
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 28,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: entrance.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Linear Progress Indicator
                      SizedBox(
                        width: 120,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: _loadingController.value,
                            backgroundColor: Colors.white.withValues(alpha: 0.6),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF8246D8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'PREPARING YOUR EXPERIENCE',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5B21B6),
                          shadows: const [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
