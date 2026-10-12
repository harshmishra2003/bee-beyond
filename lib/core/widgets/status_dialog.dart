import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';

class StatusDialog extends StatelessWidget {
  final String title;
  final String description;
  final bool isSuccess;
  final VoidCallback? onAction;
  final String? actionText;

  const StatusDialog({
    super.key,
    required this.title,
    required this.description,
    this.isSuccess = true,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            // Logo
            Image.asset(
              AssetPaths.beeBeyondImage1,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.spa_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            
            // Status Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                color: isSuccess ? const Color(0xFF10B981) : AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Action Button (Retry or other action)
            if (onAction != null && actionText != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.primary : AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAction!();
                  },
                  child: Text(
                    actionText!,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
            // Loading indicator if no action button is provided (auto-dismiss mode)
            if (onAction == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    bool isSuccess = true,
    VoidCallback? onAction,
    String? actionText,
    Duration? autoDismissAfter,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatusDialog(
        title: title,
        description: description,
        isSuccess: isSuccess,
        onAction: onAction,
        actionText: actionText,
      ),
    ).then((_) {
      if (onDismiss != null && autoDismissAfter == null) {
        // Handle manual dismiss if needed
      }
    });

    if (autoDismissAfter != null) {
      Future.delayed(autoDismissAfter, () {
        if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
          if (onDismiss != null) {
            onDismiss();
          }
        }
      });
    }
  }
}
