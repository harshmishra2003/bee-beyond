import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../constants/asset_paths.dart';
import '../network/network_provider.dart';
import '../theme/app_colors.dart';

class ConnectionLostOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectionLostOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConnectionLostOverlay> createState() => _ConnectionLostOverlayState();
}

class _ConnectionLostOverlayState extends ConsumerState<ConnectionLostOverlay> {
  bool _wasOffline = false;
  bool _showRestoredBanner = false;

  @override
  Widget build(BuildContext context) {
    final networkState = ref.watch(networkConnectivityProvider);
    final isOffline = !networkState.isConnected;

    if (_wasOffline && !isOffline) {
      _wasOffline = false;
      _triggerRestoredBanner();
    } else if (isOffline) {
      _wasOffline = true;
    }

    return Stack(
      children: [
        // Main App Content (Interactions blocked when offline)
        AbsorbPointer(
          absorbing: isOffline,
          child: widget.child,
        ),

        // Non-Dismissible Light Theme Connection Lost Overlay
        if (isOffline)
          PopScope(
            canPop: false,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Light Frosted Backdrop Blur
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: AppColors.primaryDark.withValues(alpha: 0.35),
                    ),
                  ),

                  // Center Light Card
                  Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 380),
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface, // Clean White Surface
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.badgeBg,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.18),
                              blurRadius: 35,
                              spreadRadius: 2,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pulsing Offline Badge (Light Red Pill)
                            const _LightOfflinePulsingBadge(),
                            const SizedBox(height: 20),

                            // Lottie Animation Container
                            Container(
                              height: 160,
                              width: 160,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Lottie.asset(
                                  AssetPaths.lottieConnectionLost,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFEF2F2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.wifi_off_rounded,
                                        size: 64,
                                        color: AppColors.error,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              'Connection Lost',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Subtitle Description
                            Text(
                              'It looks like you are offline. Bee Beeyond requires an active internet connection (Wi-Fi or Mobile Data) to continue.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 26),

                            // Primary Action Button with Gradient & Glow
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: networkState.isChecking
                                    ? null
                                    : () {
                                        ref
                                            .read(networkConnectivityProvider.notifier)
                                            .checkConnection();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: networkState.isChecking
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Checking Connection...',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.refresh_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Try Again',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Footer Auto-Reconnect Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.sync_rounded,
                                  size: 14,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Auto-resumes when back online',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: AppColors.textHint,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Connection Restored Top Banner (Light Theme Card)
        if (_showRestoredBanner && !isOffline)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showRestoredBanner ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA7F3D0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Internet Connection Restored',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF065F46),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _triggerRestoredBanner() {
    setState(() {
      _showRestoredBanner = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showRestoredBanner = false;
        });
      }
    });
  }
}

class _LightOfflinePulsingBadge extends StatefulWidget {
  const _LightOfflinePulsingBadge();

  @override
  State<_LightOfflinePulsingBadge> createState() => _LightOfflinePulsingBadgeState();
}

class _LightOfflinePulsingBadgeState extends State<_LightOfflinePulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnim = ColorTween(
      begin: const Color(0xFFEF4444),
      end: const Color(0xFFF59E0B),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentColor = _colorAnim.value ?? const Color(0xFFEF4444);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFCA5A5),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'OFFLINE • NO INTERNET',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF991B1B),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
