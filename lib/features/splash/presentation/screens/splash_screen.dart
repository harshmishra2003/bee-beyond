import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/router_notifier.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Fresh & Modern Splash Screen for Bee Beyonnd.
/// Features interactive hexagon honeycomb particle visuals, floating glow Orbs,
/// multi-layered rotating aura rings, animated brand entrance, and smooth Riverpod auth resolution.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _mainEntranceController;
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _progressController;

  // Animations
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;

  Timer? _minDisplayTimer;
  Timer? _safetyTimeoutTimer;
  Timer? _affirmationTimer;
  int _affirmationIndex = 0;

  bool _isMinDisplayTimePassed = false;
  bool _hasNavigated = false;

  final List<String> _affirmations = [
    "Elevating Mind & Body Harmony ✨",
    "Your Personal Sanctuary of Wellness 🌿",
    "Nurturing Peace, Strength & Vitality 🧘‍♀️",
    "Guided Wisdom for Modern Living 🍯",
    "Step Beyond into Radiant Living ✨",
  ];

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Fade & Scale with elastic curve)
    _mainEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainEntranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainEntranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainEntranceController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Continuous Ring Rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // 3. Subtle Breathing Glow Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 4. Loading Progress Line Animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // Start entrance animation
    _mainEntranceController.forward();

    // Rotate Affirmations periodic timer
    _affirmationTimer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (mounted) {
        setState(() {
          _affirmationIndex = (_affirmationIndex + 1) % _affirmations.length;
        });
      }
    });

    // Guaranteed minimum display duration for optimal user experience
    _minDisplayTimer = Timer(const Duration(milliseconds: 1400), () {
      _isMinDisplayTimePassed = true;
      _tryFinishSplash();
    });

    // Safety fallback timeout to ensure screen never hangs
    _safetyTimeoutTimer = Timer(const Duration(milliseconds: 2600), () {
      debugPrint('[SPLASH] Safety timeout triggered');
      _tryFinishSplash(force: true);
    });
  }

  void _tryFinishSplash({bool force = false}) {
    if (_hasNavigated || !mounted) return;

    final authState = ref.read(authStateProvider);

    if (force || (_isMinDisplayTimePassed && authState.status != AuthStatus.loading)) {
      _hasNavigated = true;

      _affirmationTimer?.cancel();
      _minDisplayTimer?.cancel();
      _safetyTimeoutTimer?.cancel();

      debugPrint('[SPLASH] New Splash completed. Auth status: ${authState.status}');
      ref.read(routerNotifierProvider).markSplashFinished();
    }
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    _safetyTimeoutTimer?.cancel();
    _affirmationTimer?.cancel();

    _mainEntranceController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes in auth
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status != AuthStatus.loading && mounted) {
        _tryFinishSplash();
      }
    });

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      body: Stack(
        children: [
          // 1. Interactive Ambient Glow Background Orbs
          Positioned(
            top: -size.width * 0.25,
            left: -size.width * 0.25,
            child: _buildGlowOrb(
              size: size.width * 1.1,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            right: -size.width * 0.3,
            child: _buildGlowOrb(
              size: size.width * 0.95,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.10), // Honey Warmth Glow
            ),
          ),
          Positioned(
            bottom: -size.width * 0.2,
            left: size.width * 0.1,
            child: _buildGlowOrb(
              size: size.width * 0.85,
              color: AppColors.secondary.withValues(alpha: 0.08),
            ),
          ),

          // 2. Hexagon Honeycomb Canvas Overlay
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: _HoneycombBackgroundPainter(
                  progress: _rotationController.value,
                ),
              );
            },
          ),

          // 3. Foreground Main Content Stage
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainEntranceController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),

                            // Hero Emblem & Dual Rotating Rings Stage
                            _buildHeroLogoStage(size),

                            const SizedBox(height: 28),

                            // Brand Title Banner
                            _buildBrandTitle(),

                            const SizedBox(height: 8),

                            // Subtitle Pill / Tagline
                            _buildTaglinePill(),

                            const SizedBox(height: 20),

                            // Affirmation Quote Carousel
                            _buildAffirmationCard(),

                            const SizedBox(height: 36),

                            // Loading Progress & Status Subtext
                            _buildProgressSection(),

                            const SizedBox(height: 12),
                          ],
                        ),
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

  /// Ambient Glow Orb
  Widget _buildGlowOrb({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  /// Main Hero Emblem with Double Rotating Rings & Breathing Pulse Glow
  Widget _buildHeroLogoStage(Size screenSize) {
    const double stageSize = 250.0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: stageSize,
        height: stageSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Breathing Radial Glow Background
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulseScale = 0.95 + (0.08 * _pulseController.value);
                return Transform.scale(
                  scale: pulseScale,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Continuous Rotating Dashed Dual Aura Rings
            RotationTransition(
              turns: _rotationController,
              child: SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(painter: _DualAuraRingPainter()),
              ),
            ),

            // Reverse Slow Counter-Ring Painter
            RotationTransition(
              turns: Tween<double>(begin: 1.0, end: 0.0).animate(_rotationController),
              child: SizedBox(
                width: 195,
                height: 195,
                child: CustomPaint(painter: _InnerHoneyRingPainter()),
              ),
            ),

            // Emblem Card Container
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.98 + (0.03 * _pulseController.value);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: -2,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AssetPaths.beeBeyondEmblem,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AssetPaths.beeBeyondImage1,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.eco_rounded,
                                size: 64,
                                color: AppColors.primary,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Brand Title Text with Shimmering Gradient Styling
  Widget _buildBrandTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF383577),
              Color(0xFF4B489B),
              Color(0xFF6A66C4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Bee Beyonnd',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white, // Masked by shader
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  /// Tagline Badge
  Widget _buildTaglinePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'STEPS TOWARDS PHYSICAL & MENTAL WELLBEING',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  /// Affirmation Quote Container
  Widget _buildAffirmationCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_affirmationIndex),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _affirmations[_affirmationIndex],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  /// Loading Bar & Status Indicator
  Widget _buildProgressSection() {
    return Column(
      children: [
        SizedBox(
          width: 180,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 4,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Initializing Wellness Portal...',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom Canvas Painter for Outer Dashed Dual Aura Rings
class _DualAuraRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final primaryPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final goldPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _drawDashedArc(canvas, center, radius, 0, math.pi * 0.75, primaryPaint);
    _drawDashedArc(canvas, center, radius, math.pi, math.pi * 0.75, goldPaint);
  }

  void _drawDashedArc(
      Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double currentAngle = startAngle;

    while (currentAngle < startAngle + sweepAngle) {
      final dashAngle = dashWidth / radius;
      final spaceAngle = dashSpace / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );

      currentAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Inner Slow Honey Ring Painter
class _InnerHoneyRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        math.pi / 6,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Background Hexagon Honeycomb Canvas Painter
class _HoneycombBackgroundPainter extends CustomPainter {
  final double progress;

  _HoneycombBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    const double hexRadius = 34.0;
    final double hexWidth = math.sqrt(3) * hexRadius;
    final double hexHeight = 2 * hexRadius;

    final int cols = (size.width / hexWidth).ceil() + 2;
    final int rows = (size.height / (hexHeight * 0.75)).ceil() + 2;

    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        final double xOffset = (r % 2 == 0) ? 0 : hexWidth / 2;
        final double cx = c * hexWidth + xOffset;
        final double cy = r * hexHeight * 0.75;

        _drawHexagon(canvas, Offset(cx, cy), hexRadius, paint);

        // Subtle glowing vertex dots on alternate hexagons
        if ((r + c) % 3 == 0) {
          final pulseOffset = math.sin((progress * math.pi * 2) + (r + c)) * 1.5;
          canvas.drawCircle(Offset(cx, cy), 2.0 + pulseOffset, dotPaint);
        }
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HoneycombBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
