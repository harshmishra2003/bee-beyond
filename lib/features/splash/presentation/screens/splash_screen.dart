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
  late final AnimationController _orbitController;
  late final AnimationController _lotusController;
  late final AnimationController _pulseController;

  Timer? _navigationTimer;
  Timer? _fallbackTimer;
  Timer? _affirmationTimer;
  int _affirmationIndex = 0;
  bool _hasNavigated = false;
  bool _minTimeElapsed = false;

  final List<String> _affirmations = [
    "Inhale tranquil clarity, exhale noise...",
    "Small mindful steps create radiant growth.",
    "Welcoming energy and peaceful balance today.",
    "Honor your body, calm your thought stream.",
    "Your mindful sanctuary is ready ✨",
  ];

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();

    _lotusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _affirmationTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted) {
        setState(() {
          _affirmationIndex = (_affirmationIndex + 1) % _affirmations.length;
        });
      }
    });

    // Primary splash display timer (1000ms for smooth experience)
    _navigationTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _minTimeElapsed = true;
        _tryNavigate();
      }
    });

    // Fallback timer (2200ms) to guarantee app NEVER gets stuck on splash screen
    _fallbackTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted && !_hasNavigated) {
        _minTimeElapsed = true;
        _tryNavigate(force: true);
      }
    });

    // Listen to Auth state changes once in initState cleanly
    ref.listenManual<AuthState>(authStateProvider, (previous, next) {
      if (!_hasNavigated && next.status != AuthStatus.loading) {
        _tryNavigate();
      }
    });
  }

  void _tryNavigate({bool force = false}) {
    if (_hasNavigated || !mounted || !_minTimeElapsed) return;

    final authState = ref.read(authStateProvider);

    // Wait until authentication restoration completes (unless fallback timer forces it)
    if (authState.status == AuthStatus.loading && !force) {
      return;
    }

    _hasNavigated = true;
    debugPrint('[AUTH] Navigation triggered with status: ${authState.status} (forced: $force)');

    if (authState.status == AuthStatus.authenticated) {
      context.go(RoutePaths.home);
    } else if (authState.status == AuthStatus.unauthenticated && !authState.hasSeenOnboarding) {
      context.go(RoutePaths.onboarding);
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _fallbackTimer?.cancel();
    _affirmationTimer?.cancel();
    _orbitController.dispose();
    _lotusController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: Stack(
        children: [
          // Ambient Radiant Auroras (Top & Center Gradients)
          Positioned(
            top: -100,
            left: -80,
            child: _buildOrb(420, const Color(0x4091F8AF)),
          ),
          Positioned(
            top: -60,
            right: -80,
            child: _buildOrb(380, const Color(0x60EDDCFF)),
          ),
          Positioned(
            top: size.height * 0.28,
            left: size.width * 0.5 - 170,
            child: _buildOrb(340, const Color(0x50CFACFF)),
          ),

          // Main Scrollable Content Stage
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 12),

                    // CENTERPIECE BRAND STAGE: Lotus Backdrop + Orbit Ring + Central Medallion
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Lotus Breathing Radial Aura
                          AnimatedBuilder(
                            animation: _lotusController,
                            builder: (context, child) {
                              final scale = 0.96 + 0.08 * _lotusController.value;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0x90FFFFFF),
                                        Color(0x40FFB694),
                                        Color(0x30CFACFF),
                                        Color(0x0091F8AF),
                                      ],
                                      stops: [0.0, 0.45, 0.75, 1.0],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // 2. Rotating Celestial Energy Ring
                          RotationTransition(
                            turns: _orbitController,
                            child: SizedBox(
                              width: 210,
                              height: 210,
                              child: CustomPaint(
                                painter: _OrbitRingPainter(),
                              ),
                            ),
                          ),

                          // 3. Central Medallion Card with Official Logo / Emblem
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale = 0.98 + 0.04 * _pulseController.value;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 155,
                                  height: 155,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.96),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F4A154B),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                        offset: Offset(0, 8),
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
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Floating Sparkle Dots
                          Positioned(
                            top: 18,
                            right: 35,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Color(0xFFF59E0B), blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 25,
                            left: 35,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Color(0xFF10B981), blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // CURSIVE CALLIGRAPHY SCRIPT BRAND TYPOGRAPHY: Bee Beyonnd
                    Text(
                      'Bee Beyonnd',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.greatVibes(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6845C4),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'STEPS TOWARDS PHYSICAL AND MENTAL WELLBEING',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE11D48),
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // INSPIRATIONAL HEADLINE
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Your Journey to a ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF4A154B),
                        ),
                        children: [
                          TextSpan(
                            text: 'Healthier, Happier You',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFFDB2777),
                                    Color(0xFF7E22CE),
                                    Color(0xFF4338CA),
                                  ],
                                ).createShader(const Rect.fromLTWH(0, 0, 220, 20)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Discover expert guidance, simple steps and proven daily techniques for your wellness sanctuary.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 4 MINDFULNESS PILLAR BADGES
                    Row(
                      children: [
                        Expanded(
                          child: _buildPillarCard(
                            icon: Icons.directions_run_rounded,
                            iconBgGradient: const [Color(0xFF22D3EE), Color(0xFFE0F2FE)],
                            iconColor: const Color(0xFF0891B2),
                            borderColor: const Color(0xFFCFFAFE),
                            label: 'Physical\nWellbeing',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPillarCard(
                            icon: Icons.psychology_rounded,
                            iconBgGradient: const [Color(0xFFC084FC), Color(0xFFF3E8FF)],
                            iconColor: const Color(0xFF7E22CE),
                            borderColor: const Color(0xFFF3E8FF),
                            label: 'Mental\nWellbeing',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPillarCard(
                            icon: Icons.spa_rounded,
                            iconBgGradient: const [Color(0xFFFB7185), Color(0xFFFFE4E6)],
                            iconColor: const Color(0xFFE11D48),
                            borderColor: const Color(0xFFFFE4E6),
                            label: 'Holistic\nGrowth',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPillarCard(
                            icon: Icons.eco_rounded,
                            iconBgGradient: const [Color(0xFF34D399), Color(0xFFD1FAE5)],
                            iconColor: const Color(0xFF059669),
                            borderColor: const Color(0xFFD1FAE5),
                            label: 'Healthy\nLifestyle',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // DYNAMIC MINDFUL AFFIRMATION PILL
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Container(
                        key: ValueKey(_affirmationIndex),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.spa_rounded,
                              color: Color(0xFFF59E0B),
                              size: 15,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _affirmations[_affirmationIndex],
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildOrb(double size, Color color) {
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

  Widget _buildPillarCard({
    required IconData icon,
    required List<Color> iconBgGradient,
    required Color iconColor,
    required Color borderColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: iconBgGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint1 = Paint()
      ..color = const Color(0xFF006A37).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final paint2 = Paint()
      ..color = const Color(0xFFCFACFF).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _drawDashedArc(canvas, center, radius, 0, math.pi * 0.8, paint1);
    _drawDashedArc(canvas, center, radius, math.pi, math.pi * 0.7, paint2);

    final sparkPaint = Paint()..style = PaintingStyle.fill;

    sparkPaint.color = const Color(0xFFFF7043);
    canvas.drawCircle(Offset(center.dx, center.dy - radius), 3.5, sparkPaint);

    sparkPaint.color = const Color(0xFF6E4F9A);
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 3.0, sparkPaint);

    sparkPaint.color = const Color(0xFF006A37);
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 3.0, sparkPaint);
  }

  void _drawDashedArc(
      Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 8.0;
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
