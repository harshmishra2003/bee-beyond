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
      backgroundColor: const Color(0xFF280E53),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _loadingController,
        ]),
        builder: (context, child) {
          final entrance = Curves.easeOutCubic.transform(
            _introController.value,
          );

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEBF3FC), // Sky top blend
                  Color(0xFFFAF5FF), // Middle lavender blend
                  Color(0xFF280E53), // Deep royal purple bottom blend
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. FULLY CONTAINED UNCROPPED SPLASH ARTWORK (0% Crop on any screen)
                Opacity(
                  opacity: entrance.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.96 + (0.04 * entrance),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.asset(
                          AssetPaths.splashScreenImage,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
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
                  ),
                ),

                // 2. BOTTOM FLOATING ANIMATED PROGRESS INDICATOR
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: entrance.clamp(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: _loadingController.value,
                              backgroundColor: Colors.white.withValues(alpha: 0.35),
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.amberAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PREPARING YOUR EXPERIENCE',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
