import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sign_out_dialog.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    final userName = user?.name ?? 'Guest User';
    final userEmail = user?.email ?? 'Please log in';
    final studentId = user?.studentId ?? 'N/A';

    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // BEAUTIFUL LUXURY DRAWER HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 48, 18, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0C20),
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x330F0C20),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // User Avatar with Glowing Border
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_rounded, color: Color(0xFF312E81), size: 34),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFC7D2FE),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              // VIP Tag
                              _HeaderBadge(
                                text: '✨ VIP GOLD MEMBER',
                                bgColor: Color(0xFFF59E0B),
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ID Bar
                if (user != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'STUDENT ID',
                          style: TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          studentId,
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // DRAWER MENU ITEMS LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader('LEARNING & PORTALS'),
                _DrawerTile(
                  icon: Icons.school_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'My Joined Courses',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.joinedCourses);
                  },
                ),
                _DrawerTile(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Library & Study Material',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.library);
                  },
                ),
                _DrawerTile(
                  icon: Icons.music_note_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Music & Audio Portal',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.music);
                  },
                ),
                _DrawerTile(
                  icon: Icons.ondemand_video_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Video Portal',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.video);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(height: 1),
                ),

                _buildSectionHeader('STORE & SERVICES'),
                _DrawerTile(
                  icon: Icons.local_mall_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'My Orders',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.orders);
                  },
                ),
                _DrawerTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'My Receipts & Invoices',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.receipts);
                  },
                ),
                _DrawerTile(
                  icon: Icons.shopping_cart_rounded,
                  iconColor: const Color(0xFF059669),
                  title: 'Shopping Cart',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.cart);
                  },
                ),
                _DrawerTile(
                  icon: Icons.inventory_2_rounded,
                  iconColor: const Color(0xFF0288D1),
                  title: 'Healing Products Store',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.products);
                  },
                ),
                _DrawerTile(
                  icon: Icons.support_agent_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Services & Consultations',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.services);
                  },
                ),
                _DrawerTile(
                  icon: Icons.card_membership_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: 'VIP Membership',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.membership);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(height: 1),
                ),

                _buildSectionHeader('ACCOUNT & HELP'),
                _DrawerTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF64748B),
                  title: 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.about);
                  },
                ),
                _DrawerTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Support & Contact',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.support);
                  },
                ),
                _DrawerTile(
                  icon: Icons.lock_reset_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Change Password',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.changePassword);
                  },
                ),
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Logout',
                  textColor: const Color(0xFFEF4444),
                  onTap: () {
                    Navigator.pop(context);
                    showSignOutConfirmationDialog(context, ref: ref);
                  },
                ),
              ],
            ),
          ),

          // FOOTER
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              children: [
                Image.asset(
                  AssetPaths.beeBeyondImage1,
                  height: 22,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.spa_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bee Beyonnd App v2.5.0',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _HeaderBadge({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF1E293B),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
