import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _leavesController;
  late AnimationController _entranceController;

  // Entrance Animations
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoOpacityAnim;
  late Animation<double> _taglineOpacityAnim;
  late Animation<double> _taglineSlideAnim;
  late Animation<double> _dotsOpacityAnim;

  // Typewriter Letter State
  final String _targetText = "Bee Beyonnd";
  int _visibleLetterCount = 0;

  @override
  void initState() {
    super.initState();

    // 1. Looping Leaves Swaying & Vibration Animation
    _leavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // 2. Entrance Staggered Sequence (Total 3.8s)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // Logo Emblem Spring Pop-up
    _logoScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
    );

    _logoOpacityAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    // Subtitle Taglines Slide Up & Fade
    _taglineOpacityAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.82, curve: Curves.easeIn),
    );

    _taglineSlideAnim = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.82, curve: Curves.fastOutSlowIn),
      ),
    );

    // Dots Fade-in
    _dotsOpacityAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    // One-by-One Letter Typewriter Listener
    _entranceController.addListener(() {
      const startProgress = 0.25;
      const endProgress = 0.65;

      if (_entranceController.value >= startProgress) {
        final progressInTypingPhase = ((_entranceController.value - startProgress) / (endProgress - startProgress)).clamp(0.0, 1.0);
        final count = (progressInTypingPhase * _targetText.length).ceil();
        if (count != _visibleLetterCount) {
          setState(() {
            _visibleLetterCount = count;
          });
        }
      }
    });

    // Start Entrance Animation
    _entranceController.forward();

    // Auto Navigate after sequence finishes based on Auth Session State
    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 600), () async {
          if (!mounted) return;
          
          // Check Secure Storage for Auth Token and User Data
          final secureStorage = ref.read(secureStorageProvider);
          final authToken = await secureStorage.getAuthToken();
          final userData = await secureStorage.getUserData();

          if (!mounted) return;

          // Check if user has an active authenticated session
          final bool isAuthenticated = authToken != null && 
                                       authToken.isNotEmpty && 
                                       userData != null && 
                                       userData.isNotEmpty;

          if (isAuthenticated) {
            // Logged in user goes straight to Dashboard Home
            context.go(RoutePaths.home);
          } else {
            // Unauthenticated user goes straight to Login Screen
            context.go(RoutePaths.login);
          }
        });
      }
    });
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
          // LAYER 1: Clean Elegant Background
          // -------------------------------------------------------------------
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

          // -------------------------------------------------------------------
          // LAYER 2: Floating/Vibrating Swaying Leaves Overlay
          // -------------------------------------------------------------------
          AnimatedBuilder(
            animation: _leavesController,
            builder: (context, child) {
              final t = _leavesController.value;
              final swayAngle = math.sin(t * math.pi * 2) * 0.06;
              final swayY = math.cos(t * math.pi * 2) * 6.0;
              final vibrationX = math.sin(t * math.pi * 6) * 2.0;

              return Stack(
                children: [
                  // Top-Left Swaying Leaf Branch
                  Positioned(
                    top: -10 + swayY,
                    left: -10 + vibrationX,
                    child: Transform.rotate(
                      angle: swayAngle,
                      child: _buildAnimatedLeaf(
                        width: 140,
                        height: 140,
                        color: Colors.lightGreen.withValues(alpha: 0.35),
                      ),
                    ),
                  ),

                  // Top-Right Floating Leaf Accent
                  Positioned(
                    top: size.height * 0.12 - swayY,
                    right: 20 + vibrationX,
                    child: Transform.rotate(
                      angle: -swayAngle * 1.5,
                      child: _buildAnimatedLeaf(
                        width: 50,
                        height: 50,
                        color: Colors.green.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // Middle-Left Floating Leaf
                  Positioned(
                    top: size.height * 0.35 + swayY,
                    left: 15 - vibrationX,
                    child: Transform.rotate(
                      angle: swayAngle * 2,
                      child: _buildAnimatedLeaf(
                        width: 42,
                        height: 42,
                        color: Colors.lime.withValues(alpha: 0.45),
                      ),
                    ),
                  ),

                  // Bottom-Right Swaying Branch
                  Positioned(
                    bottom: size.height * 0.12 + swayY,
                    right: -10 - vibrationX,
                    child: Transform.rotate(
                      angle: -swayAngle * 1.2,
                      child: _buildAnimatedLeaf(
                        width: 130,
                        height: 130,
                        color: Colors.green.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // -------------------------------------------------------------------
          // LAYER 3: Animated Logo, Typewriter Text & Subtitles (Overflow Proof)
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
                                  scale: _logoScaleAnim.value.clamp(0.0, 1.5),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Image.asset(
                                AssetPaths.beeBeyondImage1,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => _buildEmblemFallback(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 3B. TYPEWRITER ONE-BY-ONE LETTER ANIMATION: "Bee Beyonnd"
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                            Color(0xFF0D47A1), // Deep Royal Blue
                                            Color(0xFF1976D2), // Medium Blue
                                            Color(0xFF002171), // Dark Navy
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
                                                color: Color(0x30000000),
                                                offset: Offset(1, 2),
                                                blurRadius: 3,
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

                          const SizedBox(height: 8),

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
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFFD81B60), // Vibrant Magenta / Pink
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

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
                                color: const Color(0xFF1A237E), // Deep Indigo / Blue
                                height: 1.25,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 3E. PULSING COLOR DOTS: Magenta, Purple, Green, Grey
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
                                    _buildPulsingDot(const Color(0xFFE91E63), scale: 1.0 + 0.25 * math.sin(pulse * math.pi * 2)),
                                    const SizedBox(width: 10),
                                    _buildPulsingDot(const Color(0xFF9C27B0), scale: 1.0 + 0.25 * math.sin((pulse + 0.25) * math.pi * 2)),
                                    const SizedBox(width: 10),
                                    _buildPulsingDot(const Color(0xFF4CAF50), scale: 1.0 + 0.25 * math.sin((pulse + 0.5) * math.pi * 2)),
                                    const SizedBox(width: 10),
                                    _buildPulsingDot(const Color(0xFF78909C), scale: 1.0 + 0.25 * math.sin((pulse + 0.75) * math.pi * 2)),
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

  Widget _buildAnimatedLeaf({required double width, required double height, required Color color}) {
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
        Icons.spa,
        size: 72,
        color: AppColors.primary,
      ),
    );
  }
}
