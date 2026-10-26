import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
import '../../../../routing/route_paths.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MembershipAccessGuard(
      featureName: 'Digital Healing Library',
      featureDescription:
          'eBooks, guided videos, Binaural audio & research materials',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const CustomAppBar(title: 'Digital Healing Library'),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO ANIMATED HEADER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF312E81), // Deep Indigo
                          Color(0xFF4338CA), // Vibrant Royal Purple
                          Color(0xFF6366F1), // Electric Lavender Indigo
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x30312E81),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.amberAccent, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.amberAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BEE BEYONND VAULT',
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    'Digital Healing Library',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Access certified raga therapy audios, HD video masterclasses, downloadable Bach Flower charts & PDF reference handbooks anytime.',
                          style: TextStyle(
                            color: Color(0xFFE0E7FF),
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // QUICK STATS BADGES ROW
                        Row(
                          children: [
                            _buildHeaderStatChip(
                              icon: Icons.music_note_rounded,
                              label: '50+ Audios',
                              color: const Color(0xFFC7D2FE),
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderStatChip(
                              icon: Icons.ondemand_video_rounded,
                              label: '25+ Videos',
                              color: const Color(0xFFA7F3D0),
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderStatChip(
                              icon: Icons.menu_book_rounded,
                              label: '15+ Handbooks',
                              color: const Color(0xFFFDE68A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SECTION TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXPLORE MODULES',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Icon(Icons.apps_rounded,
                          color: AppColors.primary, size: 20),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. COLORFUL LIGHT-THEME MODULE CARDS
                  _buildColorfulModuleCard(
                    context: context,
                    title: 'Healing Music & Meditation Audio',
                    subtitle:
                        '432Hz Raga therapy, Binaural beats, Relaxing nature sounds & Sacred Mantras',
                    badgeText: '24 AUDIOS',
                    badgeBg: const Color(0xFFF3E8FF),
                    badgeTextColor: const Color(0xFF7C3AED),
                    gradientColors: const [
                      Color(0xFF8B5CF6),
                      Color(0xFF6366F1),
                    ],
                    accentBorderColor: const Color(0xFFDDD6FE),
                    icon: Icons.music_note_rounded,
                    tags: ['Raga Therapy', '432Hz Tuning', 'Guided Sleep'],
                    route: RoutePaths.music,
                  ),

                  const SizedBox(height: 14),

                  _buildColorfulModuleCard(
                    context: context,
                    title: 'Guided Video Workshops',
                    subtitle:
                        'Pranayama, Master Yoga, Vastu Shastra & Drugless Upchar video tutorials',
                    badgeText: '18 VIDEOS',
                    badgeBg: const Color(0xFFECFDF5),
                    badgeTextColor: const Color(0xFF059669),
                    gradientColors: const [
                      Color(0xFF10B981),
                      Color(0xFF0D9488),
                    ],
                    accentBorderColor: const Color(0xFFA7F3D0),
                    icon: Icons.ondemand_video_rounded,
                    tags: ['HD Tutorials', 'Practitioner Guided', 'Step-by-Step'],
                    route: RoutePaths.video,
                  ),

                  const SizedBox(height: 14),

                  _buildColorfulModuleCard(
                    context: context,
                    title: 'Books & Study PDF Materials',
                    subtitle:
                        'Bach Flower reference charts, Remedy dosage guides & Digital E-books',
                    badgeText: '12 HANDBOOKS',
                    badgeBg: const Color(0xFFFEF3C7),
                    badgeTextColor: const Color(0xFFD97706),
                    gradientColors: const [
                      Color(0xFFF59E0B),
                      Color(0xFFE11D48),
                    ],
                    accentBorderColor: const Color(0xFFFDE68A),
                    icon: Icons.menu_book_rounded,
                    tags: ['Downloadable PDFs', 'High-Res Charts', 'Offline Access'],
                    route: RoutePaths.material,
                  ),

                  const SizedBox(height: 14),

                  _buildColorfulModuleCard(
                    context: context,
                    title: 'Practitioner Support & Consultations',
                    subtitle:
                        'Connect 1-on-1 with certified Bach Flower specialists & holistic doctors',
                    badgeText: 'LIVE ASSIST',
                    badgeBg: const Color(0xFFE0F2FE),
                    badgeTextColor: const Color(0xFF0284C7),
                    gradientColors: const [
                      Color(0xFF0284C7),
                      Color(0xFF2563EB),
                    ],
                    accentBorderColor: const Color(0xFFBAE6FD),
                    icon: Icons.medical_services_rounded,
                    tags: ['1-on-1 Doctor Care', 'Custom Dosage', 'Expert Advice'],
                    route: RoutePaths.support,
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulModuleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required List<Color> gradientColors,
    required Color accentBorderColor,
    required IconData icon,
    required List<String> tags,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentBorderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C4B489B),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(route);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GRADIENT ICON BOX
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withAlpha(90),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),

                    const SizedBox(width: 14),

                    // TITLE & BADGE
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
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // FEATURE TAGS & ACTION ARROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: gradientColors.first.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: gradientColors.first,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
