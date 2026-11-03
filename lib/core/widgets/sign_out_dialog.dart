import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../utils/app_alert_manager.dart';

void showSignOutConfirmationDialog(
  BuildContext context, {
  WidgetRef? ref,
  VoidCallback? onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning/Logout Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'Are you sure you want to sign out from your account? You will need to log in again to access your enrolled courses and purchases.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
                    ),
                    onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // 1. Dismiss confirmation dialog
                      Navigator.of(dialogContext, rootNavigator: true).pop();

                      // 2. Play App Loading Animation before logging out
                      if (context.mounted) {
                        AppAlertManager.showLoading(
                          context,
                          message: "Signing out safely...",
                        );
                      }

                      // 3. Network or local cleanup delay for loading animation
                      await Future.delayed(const Duration(milliseconds: 1100));

                      // 4. Perform logout action
                      if (onConfirm != null) {
                        onConfirm();
                      } else if (ref != null) {
                        try {
                          await ref.read(authStateProvider.notifier).logout();
                        } catch (_) {}
                      }

                      // 5. Dismiss loading dialog if still mounted
                      if (context.mounted) {
                        try {
                          Navigator.of(context, rootNavigator: true).pop();
                        } catch (_) {}
                      }
                    },
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
