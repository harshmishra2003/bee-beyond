import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';

class OnboardingPageFour extends StatefulWidget {
  const OnboardingPageFour({super.key});

  @override
  State<OnboardingPageFour> createState() => _OnboardingPageFourState();
}

class _OnboardingPageFourState extends State<OnboardingPageFour>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Main Headline
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Ready to Begin Your ',
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  height: 1.25,
                ),
                children: [
                  TextSpan(
                    text: 'Journey',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF006A37),
                            Color(0xFF6E4F9A),
                            Color(0xFF9C3E00),
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 20)),
                    ),
                  ),
                  TextSpan(
                    text: '?',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Bee Beyonnd is your personal sanctuary gently guiding you towards holistic physical, mental & spiritual balance.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // Central Showcase Stage: Medallion with Orbiting Charms (Body, Mind, Soul)
          Center(
            child: SizedBox(
              width: 230,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Luminous Aura Halo
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glow = 0.15 + 0.15 * _pulseController.value;
                      return Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF006A37).withValues(alpha: glow),
                              const Color(0xFF6E4F9A).withValues(alpha: glow * 0.8),
                              const Color(0xFF9C3E00).withValues(alpha: glow * 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Rotating Sacred Geometry Ring
                  RotationTransition(
                    turns: _orbitController,
                    child: SizedBox(
                      width: 190,
                      height: 190,
                      child: CustomPaint(
                        painter: _MandalaRingPainter(),
                      ),
                    ),
                  ),

                  // Central Medallion Circle
                  Container(
                    width: 135,
                    height: 135,
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

                  // Orbiting Pillar Charm 2: Bottom Left - Mind
                  Positioned(
                    bottom: 12,
                    left: 4,
                    child: _buildOrbitPillarTag(
                      color: const Color(0xFF6E4F9A),
                      label: 'Mind',
                    ),
                  ),

                  // Orbiting Pillar Charm 3: Bottom Right - Soul
                  Positioned(
                    bottom: 12,
                    right: 4,
                    child: _buildOrbitPillarTag(
                      color: const Color(0xFF9C3E00),
                      label: 'Soul',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Your Three Pillars of Growth Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR THREE PILLARS OF GROWTH',
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB6E8C0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF006A37),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Holistic Care',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006A37),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pillar 1: Physical Vitality
          _buildPillarGrowthTile(
            icon: Icons.spa_rounded,
            iconBgColor: const Color(0xFFE6F4EA),
            iconColor: const Color(0xFF006A37),
            title: 'Physical Vitality',
            badgeText: 'Daily Rituals',
            badgeBg: const Color(0xFFE6F4EA),
            badgeColor: const Color(0xFF006A37),
            subtitle: 'Ayurveda · Therapeutic Yoga · Restorative Diet',
          ),

          const SizedBox(height: 10),

          // Pillar 2: Mental Clarity
          _buildPillarGrowthTile(
            icon: Icons.psychology_alt_rounded,
            iconBgColor: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF6E4F9A),
            title: 'Mental Clarity',
            badgeText: 'Drugless Care',
            badgeBg: const Color(0xFFF3E8FF),
            badgeColor: const Color(0xFF563781),
            subtitle: 'Bach Flower · DMIT Brain Mapping · Counseling',
          ),

          const SizedBox(height: 10),

          // Pillar 3: Spiritual Harmony
          _buildPillarGrowthTile(
            icon: Icons.self_improvement_rounded,
            iconBgColor: const Color(0xFFFFDBCC),
            iconColor: const Color(0xFF9C3E00),
            title: 'Spiritual Harmony',
            badgeText: 'Inner Balance',
            badgeBg: const Color(0xFFFFDBCC),
            badgeColor: const Color(0xFF7B2F00),
            subtitle: 'Pranayama · Vastu Alignments · Chakra Energy',
          ),

          const SizedBox(height: 18),

          // Today's Intention Banner Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFF006A37),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S INTENTION",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF006A37),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"One small mindful step each day blossoms into a lifetime of radiant health and inner stillness."',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOrbitPillarTag({required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarGrowthTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: Color(0xFF006A37),
            ),
          ),
        ],
      ),
    );
  }
}

class _MandalaRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint1 = Paint()
      ..color = const Color(0xFF006A37).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawDashedArc(canvas, center, radius, 0, math.pi * 2, paint1);

    final sparkPaint = Paint()..style = PaintingStyle.fill;

    sparkPaint.color = const Color(0xFF006A37);
    canvas.drawCircle(Offset(center.dx, center.dy - radius), 3.5, sparkPaint);

    sparkPaint.color = const Color(0xFF6E4F9A);
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 3.5, sparkPaint);

    sparkPaint.color = const Color(0xFF9C3E00);
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 3.5, sparkPaint);
  }

  void _drawDashedArc(
      Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Paint paint) {
    const dashWidth = 6.0;
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
