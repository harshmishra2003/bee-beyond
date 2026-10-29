import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/membership/presentation/providers/expiry_provider.dart';
import '../../routing/route_paths.dart';
import '../services/expiry_manager_service.dart';

class ExpiryAlertBanner extends ConsumerWidget {
  const ExpiryAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePass = ref.watch(activePassProvider);
    if (activePass == null) return const SizedBox.shrink();

    final status = activePass.status;
    if (status == AccessStatus.active) return const SizedBox.shrink();

    Color bgColor = const Color(0xFFFFFBEB); // Light Amber
    Color borderColor = const Color(0xFFF59E0B);
    Color textColor = const Color(0xFF78350F);
    IconData icon = Icons.access_time_filled_rounded;
    String title = 'VIP Pass Expiring Soon!';
    String message =
        '${activePass.passName} expires in ${ExpiryManagerService.calculateDaysRemaining(activePass.expiresAt)} days. Tap to renew now.';

    if (status == AccessStatus.gracePeriod) {
      bgColor = const Color(0xFFFEF2F2); // Light Red
      borderColor = const Color(0xFFEF4444);
      textColor = const Color(0xFF991B1B);
      icon = Icons.warning_rounded;
      title = 'VIP Pass Expired (Grace Period Active)';
      message =
          'Your pass expired. Renew now to avoid losing access to remedies & courses.';
    } else if (status == AccessStatus.expired) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFEF4444);
      textColor = const Color(0xFF991B1B);
      icon = Icons.error_rounded;
      title = 'VIP Pass Expired';
      message =
          'Your membership pass has expired. Tap to reactivate your VIP access.';
    }

    return GestureDetector(
      onTap: () => context.push(RoutePaths.membership),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: borderColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.85),
                      fontSize: 10.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'RENEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
