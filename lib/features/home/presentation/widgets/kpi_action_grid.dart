import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';

class KPIActionItem {
  final String title;
  final String? assetPath;
  final IconData? fallbackIcon;
  final String route;

  const KPIActionItem({
    required this.title,
    this.assetPath,
    this.fallbackIcon,
    required this.route,
  });
}

class KPIActionGrid extends StatelessWidget {
  final Function(String route) onItemTap;

  const KPIActionGrid({
    super.key,
    required this.onItemTap,
  });

  static const List<KPIActionItem> items = [
    KPIActionItem(
      title: 'WORKSHOPS',
      fallbackIcon: Icons.workspace_premium_rounded,
      route: RoutePaths.workshops,
    ),
    KPIActionItem(
      title: 'MATERIAL',
      assetPath: 'assets/icons/books.png',
      fallbackIcon: Icons.collections_bookmark_rounded,
      route: RoutePaths.material,
    ),
    KPIActionItem(
      title: 'PRODUCTS',
      fallbackIcon: Icons.inventory_2_outlined,
      route: RoutePaths.products,
    ),
    KPIActionItem(
      title: 'SERVICES',
      assetPath: 'assets/icons/customer-service.png',
      fallbackIcon: Icons.support_agent_rounded,
      route: RoutePaths.services,
    ),
    KPIActionItem(
      title: 'COURSES',
      fallbackIcon: Icons.school_outlined,
      route: RoutePaths.courses,
    ),
    KPIActionItem(
      title: 'MUSIC',
      assetPath: 'assets/icons/audio.png',
      fallbackIcon: Icons.music_note_rounded,
      route: RoutePaths.music,
    ),
    KPIActionItem(
      title: 'VIDEO',
      fallbackIcon: Icons.ondemand_video_rounded,
      route: RoutePaths.video,
    ),
    KPIActionItem(
      title: 'MEMBERSHIP',
      assetPath: 'assets/icons/membership.png',
      fallbackIcon: Icons.card_membership_rounded,
      route: RoutePaths.membership,
    ),
  ];

  // Single Beautiful Multicolour Combination Gradient Frame for all options
  static const LinearGradient multicolourFrameGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // Royal Violet
      Color(0xFFEC4899), // Neon Pink
      Color(0xFF3B82F6), // Ocean Blue
      Color(0xFF10B981), // Emerald Teal
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.94,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap(item.route),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SURROUNDED WITH SINGLE MULTICOLOUR COMBINATION GRADIENT FRAME
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2.5), // Multicolour Frame Surround Thickness
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: multicolourFrameGradient, // Vibrant Multicolour Surround
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x308B5CF6),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Inner Clean White Circle Body
                    ),
                    child: item.assetPath != null
                        ? Image.asset(
                            item.assetPath!,
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              item.fallbackIcon ?? Icons.grid_view_rounded,
                              size: 28,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            item.fallbackIcon ?? Icons.grid_view_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                // Text Label with FittedBox to prevent text overflow or mid-word breaking
                SizedBox(
                  height: 16,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
