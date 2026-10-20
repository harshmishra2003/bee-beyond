import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';

class AuthBackgroundWrapper extends StatefulWidget {
  final Widget child;
  final bool showBackButton;

  const AuthBackgroundWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  @override
  State<AuthBackgroundWrapper> createState() => _AuthBackgroundWrapperState();
}

class _AuthBackgroundWrapperState extends State<AuthBackgroundWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _leavesController;

  @override
  void initState() {
    super.initState();
    _leavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _leavesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Clean Elegant Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFAF9FE),
                    Color(0xFFFFFFFF),
                    Color(0xFFF2F0FC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Floating Leaves Animation Overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _leavesController,
              builder: (context, child) {
                final t = _leavesController.value;
                final swayAngle = math.sin(t * math.pi * 2) * 0.05;
                final swayY = math.cos(t * math.pi * 2) * 5.0;
                final vibrationX = math.sin(t * math.pi * 6) * 1.8;

                return Stack(
                  children: [
                    Positioned(
                      top: -5 + swayY,
                      left: -5 + vibrationX,
                      child: Transform.rotate(
                        angle: swayAngle,
                        child: _buildLeafShape(width: 120, height: 120, color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                    ),

                    Positioned(
                      top: size.height * 0.08 - swayY,
                      right: 15 + vibrationX,
                      child: Transform.rotate(
                        angle: -swayAngle * 1.4,
                        child: _buildLeafShape(width: 45, height: 45, color: AppColors.primaryLight.withValues(alpha: 0.2)),
                      ),
                    ),

                    Positioned(
                      bottom: size.height * 0.08 + swayY,
                      right: -5 - vibrationX,
                      child: Transform.rotate(
                        angle: -swayAngle * 1.2,
                        child: _buildLeafShape(width: 110, height: 110, color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Scrollable Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Top Left Back Navigation Icon (Only show if explicitly requested and pop-able)
                    if (widget.showBackButton && canPop)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 28),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            } else {
                              context.go(RoutePaths.home);
                            }
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Official Brand Banner Logo Image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Image.asset(
                        AssetPaths.beeBeyondImage1,
                        height: 76,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.spa_rounded, size: 50, color: AppColors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Form Card Child Widget
                    widget.child,

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeafShape({required double width, required double height, required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
    );
  }
}
