import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';

class OnboardingPageOne extends StatefulWidget {
  const OnboardingPageOne({super.key});

  @override
  State<OnboardingPageOne> createState() => _OnboardingPageOneState();
}

class _OnboardingPageOneState extends State<OnboardingPageOne>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          // Centerpiece Stage: Medallion + Rotating Energy Rings
          SizedBox(
            width: 210,
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Breathing Aura Glow
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = 0.15 + 0.15 * _pulseController.value;
                    return Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF006A37).withValues(alpha: glow),
                            const Color(0xFF6E4F9A).withValues(alpha: glow * 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Rotating Celestial Energy Ring
                RotationTransition(
                  turns: _orbitController,
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: _OnboardingOrbitRingPainter(),
                    ),
                  ),
                ),

                // Central Medallion Circle
                Container(
                  width: 130,
                  height: 130,
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
                        color: Color(0x1A6E4F9A),
                        blurRadius: 24,
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

                // Orbiting Sparkle Nodes
                Positioned(
                  top: 14,
                  right: 30,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF58220),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 30,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF109B4C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Cursive Script Brand Title
          Text(
            'Bee Beyonnd',
            textAlign: TextAlign.center,
            style: GoogleFonts.greatVibes(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B1B6D),
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
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 16),

          // Main Welcome Heading
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Welcome to ',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              children: [
                TextSpan(
                  text: 'Bee ',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6845C4),
                  ),
                ),
                TextSpan(
                  text: 'Beyonnd',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006A37),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Description Text
          Text(
            'Your trusted companion for holistic wellness, certified restorative courses, and natural drugless therapies.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // 3 Mindfulness Pillar Chips Row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPillChip(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF006A37),
                bgColor: const Color(0xFFE6F4EA),
                label: 'Physical Health',
              ),
              _buildPillChip(
                icon: Icons.self_improvement_rounded,
                iconColor: const Color(0xFF6845C4),
                bgColor: const Color(0xFFF3E8FF),
                label: 'Mental Clarity',
              ),
              _buildPillChip(
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                label: 'Drugless Healing',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Holistic Community Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6845C4), Color(0xFF006A37)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Holistic Community',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4EA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '12k+ Active',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006A37),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Guided sessions & doctor-certified natural paths.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
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

  Widget _buildPillChip({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingOrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint1 = Paint()
      ..color = const Color(0xFF006A37).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint2 = Paint()
      ..color = const Color(0xFF6845C4).withValues(alpha: 0.35)
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
