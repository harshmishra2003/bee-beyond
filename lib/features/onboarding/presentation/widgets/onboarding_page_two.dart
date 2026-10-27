import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPageTwo extends StatefulWidget {
  const OnboardingPageTwo({super.key});

  @override
  State<OnboardingPageTwo> createState() => _OnboardingPageTwoState();
}

class _OnboardingPageTwoState extends State<OnboardingPageTwo> {
  int _selectedTherapyIndex = 0;

  final List<Map<String, dynamic>> _therapies = [
    {
      'title': 'Bach Flower',
      'icon': Icons.local_florist_rounded,
      'gradient': [const Color(0xFFF43F5E), const Color(0xFFFB7185)],
      'bgColor': const Color(0xFFFFE4E6),
      'borderColor': const Color(0xFFFECDD3),
      'textColor': const Color(0xFF9F1239),
    },
    {
      'title': 'Vastu Shastra',
      'icon': Icons.home_rounded,
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      'bgColor': const Color(0xFFFEF3C7),
      'borderColor': const Color(0xFFFDE68A),
      'textColor': const Color(0xFF78350F),
    },
    {
      'title': 'Graphology',
      'icon': Icons.edit_note_rounded,
      'gradient': [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
      'bgColor': const Color(0xFFCCFBF1),
      'borderColor': const Color(0xFF99F6E4),
      'textColor': const Color(0xFF115E59),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-Tag Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA), Color(0xFFFFF1F2)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFA7F3D0),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF059669),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  'HOLISTIC WELLNESS ECOSYSTEM',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Headline
          RichText(
            text: TextSpan(
              text: 'Harmonize Your ',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1.25,
              ),
              children: [
                TextSpan(
                  text: 'Mind & Energy',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF059669),
                          Color(0xFF0D9488),
                          Color(0xFF6845C4),
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 220, 20)),
                  ),
                ),
                TextSpan(
                  text: ' Balance',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Comprehensive drugless therapies curated to restore inner equilibrium, clear emotional debris, and awaken personal vibrancy.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Therapeutic Approaches Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'THERAPEUTIC APPROACHES',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('✨', style: TextStyle(fontSize: 12)),
                ],
              ),
              Text(
                'Touch to explore',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF047857),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3 Selectable Therapy Tabs Row
          Row(
            children: List.generate(_therapies.length, (index) {
              final isSelected = index == _selectedTherapyIndex;
              final t = _therapies[index];

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < _therapies.length - 1 ? 8.0 : 0.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTherapyIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? t['bgColor'] as Color : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? t['textColor'] as Color : const Color(0xFFE2E8F0),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? (t['textColor'] as Color).withValues(alpha: 0.2)
                                : const Color(0x0A000000),
                            blurRadius: isSelected ? 10 : 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: t['gradient'] as List<Color>,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (t['gradient'] as List<Color>).first.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              t['icon'] as IconData,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t['title'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? t['textColor'] as Color : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Prescribed Pathways Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Prescribed Pathways',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3 Modules Available',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7E22CE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pathway Card 1: Emotional & Mind Release
          _buildPathwayCard(
            gradientColors: const [Color(0xFF7E22CE), Color(0xFFD946EF)],
            icon: Icons.psychology_rounded,
            title: 'Emotional & Mind Release',
            badgeText: '✨ Natural Harmony',
            badgeBg: const Color(0xFFF3E8FF),
            badgeColor: const Color(0xFF7E22CE),
            description:
                'Breathwork, somatic resetting, and subtle vibrational remedies to dissolve deep-seated emotional strain.',
          ),

          const SizedBox(height: 12),

          // Pathway Card 2: Vastu & Positive Energy
          _buildPathwayCard(
            gradientColors: const [Color(0xFFF59E0B), Color(0xFFF43F5E)],
            icon: Icons.brightness_7_rounded,
            title: 'Vastu & Positive Energy',
            badgeText: '☀️ Spatial Aura',
            badgeBg: const Color(0xFFFEF3C7),
            badgeColor: const Color(0xFFB45309),
            description:
                'Rebalance living and workspace geo-frequencies to invite prosperity, serene flow, and calm abundance.',
          ),

          const SizedBox(height: 12),

          // Pathway Card 3: DMIT & Personality Coaching
          _buildPathwayCard(
            gradientColors: const [Color(0xFF059669), Color(0xFF0D9488)],
            icon: Icons.fingerprint_rounded,
            title: 'DMIT & Personality Coaching',
            badgeText: '🌱 Inner Blueprint',
            badgeBg: const Color(0xFFD1FAE5),
            badgeColor: const Color(0xFF047857),
            description:
                'Discover intrinsic cognitive patterns, sensory strengths, and psychological clarity for mindful life paths.',
          ),

          const SizedBox(height: 20),

          // Mindful Insight Quote Banner Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFFF1F2), Color(0xFFFAF5FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
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
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFE11D48), Color(0xFF7E22CE)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'MINDFUL INSIGHT',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFBE123C),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"Healing begins when thoughts settle, frequencies align, and nature guides the pulse."',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12.5,
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

  Widget _buildPathwayCard({
    required List<Color> gradientColors,
    required IconData icon,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
