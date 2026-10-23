import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/membership_access_guard.dart';
import '../../../../routing/route_paths.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MembershipAccessGuard(
      featureName: 'Digital Healing Library',
      featureDescription: 'eBooks, guided videos, Binaural audio & research materials',
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Digital Healing Library'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x184B489B),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Bee Beeyond Digital Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore raga therapy audio tracks, video tutorials, Bach Flower charts, and downloadable study guides.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Library Categories
            _buildLibraryCard(
              context: context,
              icon: Icons.music_note_rounded,
              iconBg: const Color(0xFFF2F0FC),
              title: 'Healing Music & Meditation Audio',
              subtitle: 'Raga therapy, Binaural beats, Relaxing sounds & Mantras',
              badgeText: '24 Tracks',
              route: RoutePaths.music,
            ),
            const SizedBox(height: 12),
            _buildLibraryCard(
              context: context,
              icon: Icons.ondemand_video_rounded,
              iconBg: const Color(0xFFEFF8F6),
              title: 'Guided Video Workshops',
              subtitle: 'Pranayama, Yoga, Vastu Shastra & Drugless Upchar tutorials',
              badgeText: '18 Videos',
              route: RoutePaths.video,
            ),
            const SizedBox(height: 12),
            _buildLibraryCard(
              context: context,
              icon: Icons.collections_bookmark_rounded,
              iconBg: const Color(0xFFFFF7ED),
              title: 'Books & Study PDF Materials',
              subtitle: 'Bach Flower reference charts, Remedy guides & Ebooks',
              badgeText: '12 PDFs',
              route: RoutePaths.material,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildLibraryCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badgeText,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x104B489B),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
