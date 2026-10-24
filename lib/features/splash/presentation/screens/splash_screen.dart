import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
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
  // Animation Controllers
  late AnimationController _leavesController;
  late AnimationController _entranceController;

  // Entrance Animations
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoOpacityAnim;
  late Animation<double> _taglineOpacityAnim;
  late Animation<double> _taglineSlideAnim;
  late Animation<double> _dotsOpacityAnim;

  // Typewriter Target Branding String
  final String _targetText = "Bee Beyonnd";
  int _visibleLetterCount = 0;

  @override
  void initState() {
    super.initState();

    // 1. Looping Leaves & Subtle Floating Ambient Particle Animation
    _leavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    // 2. Entrance Staggered Sequence (Total 3.8s)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // Logo Emblem Spring Pop-up
    _logoScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.38, curve: Curves.elasticOut),
    );

    _logoOpacityAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    // Tagline Slogan & Subtitles Slide Up & Fade
    _taglineOpacityAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
    );

    _taglineSlideAnim = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.85, curve: Curves.fastOutSlowIn),
      ),
    );

    // Pulsing Dots Fade-in
    _dotsOpacityAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    // Typewriter Letter Animation Listener
    _entranceController.addListener(() {
      const startProgress = 0.22;
      const endProgress = 0.65;

      if (_entranceController.value >= startProgress) {
        final progressInTypingPhase =
            ((_entranceController.value - startProgress) /
                    (endProgress - startProgress))
                .clamp(0.0, 1.0);
        final count = (progressInTypingPhase * _targetText.length).ceil();
        if (count != _visibleLetterCount) {
          setState(() {
            _visibleLetterCount = count;
          });
        }
      }
    });

    // Auto-navigate after entrance animation completes
    _entranceController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          final authState = ref.read(authStateProvider);
          if (authState.status == AuthStatus.authenticated) {
            context.go(RoutePaths.home);
          } else if (!authState.hasSeenOnboarding) {
            context.go(RoutePaths.onboarding);
          } else {
            context.go(RoutePaths.login);
          }
        }
      }
    });

    // Start Entrance Animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _leavesController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // -------------------------------------------------------------------
          // LAYER 1: Clean Soft Ambient Gradient Background
          // -------------------------------------------------------------------
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFAFAF9),
                    Color(0xFFFFFFFF),
                    Color(0xFFF1F5F9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Glowing Radial Background Aura
          Positioned(
            top: size.height * 0.22,
            left: size.width * 0.5 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x1810B981),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1F6366F1).withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // LAYER 2: Floating Nature Leaves Overlay Animation
          // -------------------------------------------------------------------
          AnimatedBuilder(
            animation: _leavesController,
            builder: (context, child) {
              final t = _leavesController.value;
              final swayAngle = math.sin(t * math.pi * 2) * 0.07;
              final swayY = math.cos(t * math.pi * 2) * 7.0;
              final vibrationX = math.sin(t * math.pi * 6) * 2.5;

              return Stack(
                children: [
                  // Top-Left Leaf Accent
                  Positioned(
                    top: -12 + swayY,
                    left: -12 + vibrationX,
                    child: Transform.rotate(
                      angle: swayAngle,
                      child: _buildAnimatedLeaf(
                        width: 145,
                        height: 145,
                        color: Colors.green.withValues(alpha: 0.25),
                      ),
                    ),
                  ),

                  // Top-Right Floating Leaf Accent
                  Positioned(
                    top: size.height * 0.12 - swayY,
                    right: 22 + vibrationX,
                    child: Transform.rotate(
                      angle: -swayAngle * 1.5,
                      child: _buildAnimatedLeaf(
                        width: 52,
                        height: 52,
                        color: Colors.lightGreen.withValues(alpha: 0.35),
                      ),
                    ),
                  ),

                  // Middle-Left Floating Leaf Accent
                  Positioned(
                    top: size.height * 0.36 + swayY,
                    left: 18 - vibrationX,
                    child: Transform.rotate(
                      angle: swayAngle * 2,
                      child: _buildAnimatedLeaf(
                        width: 44,
                        height: 44,
                        color: Colors.lime.withValues(alpha: 0.40),
                      ),
                    ),
                  ),

                  // Bottom-Right Swaying Branch Accent
                  Positioned(
                    bottom: size.height * 0.12 + swayY,
                    right: -12 - vibrationX,
                    child: Transform.rotate(
                      angle: -swayAngle * 1.2,
                      child: _buildAnimatedLeaf(
                        width: 135,
                        height: 135,
                        color: Colors.teal.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // -------------------------------------------------------------------
          // LAYER 3: Animated Logo, Name & Taglines
          // -------------------------------------------------------------------
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),

                          // 3A. POP-UP OFFICIAL LOGO BANNER
                          AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _logoOpacityAnim.value,
                                child: Transform.scale(
                                  scale: _logoScaleAnim.value.clamp(0.0, 1.4),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Image.asset(
                                AssetPaths.beeBeyondImage1,
                                height: 110,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildEmblemFallback(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 3B. TYPEWRITER ONE-BY-ONE LETTER ANIMATION: "Bee Beyonnd"
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(_targetText.length, (index) {
                                  final isVisible = index < _visibleLetterCount;
                                  final char = _targetText[index];

                                  return AnimatedOpacity(
                                    duration: const Duration(milliseconds: 180),
                                    opacity: isVisible ? 1.0 : 0.0,
                                    child: AnimatedScale(
                                      duration: const Duration(milliseconds: 220),
                                      scale: isVisible ? 1.0 : 0.3,
                                      curve: Curves.easeOutBack,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFF0284C7), // Bright Ocean Blue
                                            Color(0xFF1D4ED8), // Deep Royal Blue
                                            Color(0xFF1E3A8A), // Dark Navy
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ).createShader(bounds),
                                        child: Text(
                                          char == ' ' ? '  ' : char,
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                            shadows: [
                                              const Shadow(
                                                color: Color(0x20000000),
                                                offset: Offset(1, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 3C. TAGLINE 1: "STEPS TOWARDS PHYSICAL AND MENTAL WELLBEING"
                          AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _taglineOpacityAnim.value,
                                child: Transform.translate(
                                  offset: Offset(0, _taglineSlideAnim.value),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'STEPS TOWARDS PHYSICAL AND MENTAL WELLBEING',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: const Color(0xFFE11D48), // Vibrant Magenta / Rose
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 3D. TAGLINE 2: "A Healthier You Starts Here..."
                          AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _taglineOpacityAnim.value,
                                child: Transform.translate(
                                  offset: Offset(0, _taglineSlideAnim.value),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              'A Healthier You\nStarts Here...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF1E1B4B), // Indigo Navy
                                height: 1.25,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 3E. PULSING COLOR DOTS: Rose, Purple, Emerald, Slate
                          AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _dotsOpacityAnim.value,
                                child: child,
                              );
                            },
                            child: AnimatedBuilder(
                              animation: _leavesController,
                              builder: (context, child) {
                                final pulse = _leavesController.value;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildPulsingDot(const Color(0xFFE11D48),
                                        scale: 1.0 + 0.25 * math.sin(pulse * math.pi * 2)),
                                    const SizedBox(width: 10),
                                    _buildPulsingDot(const Color(0xFF9333EA),
                                        scale: 1.0 +
                                            0.25 * math.sin((pulse + 0.25) * math.pi * 2)),
                                    const SizedBox(width: 10),
                                    _buildPulsingDot(const Color(0xFF10B981),
                                        scale: 1.0 +
                                            0.25 * math.sin((pulse + 0.5) * math.pi * 2)),
                                    const SizedBox(width: 10),
                                    _buildPulsingDot(const Color(0xFF64748B),
                                        scale: 1.0 +
                                            0.25 * math.sin((pulse + 0.75) * math.pi * 2)),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------

  Widget _buildAnimatedLeaf(
      {required double width, required double height, required Color color}) {
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

  Widget _buildPulsingDot(Color color, {required double scale}) {
    return Transform.scale(
      scale: scale.clamp(0.8, 1.4),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmblemFallback() {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.spa_rounded,
        size: 72,
        color: AppColors.primary,
      ),
    );
  }
}
