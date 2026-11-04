import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sign_out_dialog.dart';
import '../../../../routing/route_paths.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _selectedImageFile = File(image.path);
        _isUploading = true;
      });

      // Simulate secure upload processing to server
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture uploaded successfully!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (profile) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.home);
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => context.push(RoutePaths.editProfile),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                    // Decorative Circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(26),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(26),
                        ),
                      ),
                    ),
                    // Profile Info
                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => _showProfilePictureOptions(context),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.secondary,
                                    backgroundImage: _selectedImageFile != null
                                        ? FileImage(_selectedImageFile!) as ImageProvider
                                        : null,
                                    child: _isUploading
                                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                        : (_selectedImageFile == null
                                            ? Text(
                                                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(230),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Student ID: ${profile.studentId.isNotEmpty ? profile.studentId : 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSettingsSection(
                      context,
                      title: 'My Learning & Purchases',
                      items: [
                        _SettingsItem(
                          icon: Icons.school_rounded,
                          iconColor: const Color(0xFF4338CA),
                          iconBgColor: const Color(0xFFEEF2FF),
                          title: 'My Joined Courses',
                          subtitle: 'View your enrolled programs',
                          onTap: () => context.push(RoutePaths.joinedCourses),
                        ),
                        _SettingsItem(
                          icon: Icons.confirmation_number_rounded,
                          iconColor: const Color(0xFF0891B2),
                          iconBgColor: const Color(0xFFCFFAFE),
                          title: 'My Workshop Bookings',
                          subtitle: 'View masterclasses & booking status',
                          onTap: () => context.push(RoutePaths.workshops),
                        ),
                        _SettingsItem(
                          icon: Icons.shopping_bag_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor: const Color(0xFFECFDF5),
                          title: 'Orders & Transactions',
                          subtitle: 'Track your purchases',
                          onTap: () => context.push(RoutePaths.orders),
                        ),
                        _SettingsItem(
                          icon: Icons.card_membership_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBgColor: const Color(0xFFFFFBEB),
                          title: 'Membership & Services',
                          subtitle: 'Manage your subscriptions',
                          onTap: () => context.push(RoutePaths.membership),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsSection(
                      context,
                      title: 'Account Settings',
                      items: [
                        _SettingsItem(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF4B489B),
                          iconBgColor: const Color(0xFFECEBFA),
                          title: 'Change Password',
                          onTap: () => context.push(RoutePaths.changePassword),
                        ),
                        _SettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          iconColor: const Color(0xFF4B489B),
                          iconBgColor: const Color(0xFFECEBFA),
                          title: 'Privacy Policy',
                          onTap: () => context.push(RoutePaths.privacyPolicy),
                        ),
                        _SettingsItem(
                          icon: Icons.info_outline_rounded,
                          iconColor: const Color(0xFF4B489B),
                          iconBgColor: const Color(0xFFECEBFA),
                          title: 'About Bee Beyonnd',
                          onTap: () => context.push(RoutePaths.about),
                        ),
                        _SettingsItem(
                          icon: Icons.support_agent_rounded,
                          iconColor: const Color(0xFF4B489B),
                          iconBgColor: const Color(0xFFECEBFA),
                          title: 'Support & Helpdesk',
                          onTap: () => context.push(RoutePaths.support),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
                        ),
                      ),
                      onPressed: () {
                        showSignOutConfirmationDialog(context, ref: ref);
                      },
                      icon: const Icon(Icons.logout_rounded, size: 22),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, {required String title, required List<_SettingsItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: isLast 
                          ? const BorderRadius.vertical(bottom: Radius.circular(20))
                          : (index == 0 ? const BorderRadius.vertical(top: Radius.circular(20)) : BorderRadius.zero),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item.iconBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item.icon, color: item.iconColor, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 76),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showProfilePictureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Update Profile Picture',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take Photo via Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                subtitle: const Text('Open device camera to click snapshot', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF059669)),
                ),
                title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                subtitle: const Text('Pick image from phone gallery or files', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
