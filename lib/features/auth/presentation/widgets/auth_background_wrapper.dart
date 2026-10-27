import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';

class AuthBackgroundWrapper extends StatefulWidget {
  final Widget child;
  final bool showBackButton;

  const AuthBackgroundWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  @override
  State<AuthBackgroundWrapper> createState() => _AuthBackgroundWrapperState();
}

class _AuthBackgroundWrapperState extends State<AuthBackgroundWrapper>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FE),
      body: Stack(
        children: [
          // -------------------------------------------------------------------
          // LAYER 1: Ambient Mesh Backdrop & Auroras
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

          // Top Left Warm Orange Blob
          Positioned(
            top: -40,
            left: -60,
            child: _buildBlob(280, const Color(0x35FED7AA)),
          ),

          // Top Right Rose Violet Blob
          Positioned(
            top: -20,
            right: -60,
            child: _buildBlob(300, const Color(0x30F472B6)),
          ),

          // Bottom Right Emerald Purple Blob
          Positioned(
            bottom: -20,
            right: -60,
            child: _buildBlob(300, const Color(0x30109B4C)),
          ),

          // -------------------------------------------------------------------
          // LAYER 2: Main Scrollable Form Stage
          // -------------------------------------------------------------------
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Top Navigation Back Button (Only if showBackButton & canPop)
                    if (widget.showBackButton && canPop)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            } else {
                              context.go(RoutePaths.home);
                            }
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // HERO BRAND SHOWCASE: Medallion + Energy Rings + Brand Text
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Luminous Breathing Glow
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final glow = 0.15 + 0.15 * _pulseController.value;
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF4C3592).withValues(alpha: glow),
                                      const Color(0xFFE82574).withValues(alpha: glow * 0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Rotating Celestial Outer Ring
                          RotationTransition(
                            turns: _orbitController,
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: _AuthOrbitRingPainter(),
                              ),
                            ),
                          ),

                          // Central White Logo Medallion
                          Container(
                            width: 110,
                            height: 110,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x184C3592),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: Offset(0, 6),
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

                          // Orbiting Energy Sparkles
                          Positioned(
                            top: 8,
                            right: 20,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE82574),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 18,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF109B4C),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Cursive Script Brand Title
                    Text(
                      'Bee Beyonnd',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dancingScript(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF382481),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'STEPS TOWARDS PHYSICAL AND MENTAL WELLBEING',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE82574),
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Form Card Child
                    widget.child,

                    const SizedBox(height: 16),

                    // Reassurance Privacy Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF059669),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Protected with holistic privacy encryption',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _AuthOrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint1 = Paint()
      ..color = const Color(0xFF6845C4).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint2 = Paint()
      ..color = const Color(0xFFE82574).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawDashedArc(canvas, center, radius, 0, math.pi * 0.8, paint1);
    _drawDashedArc(canvas, center, radius, math.pi, math.pi * 0.7, paint2);
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
