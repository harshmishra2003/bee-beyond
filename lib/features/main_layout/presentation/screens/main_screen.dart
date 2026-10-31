import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auto_data_sync_service.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/connection_lost_overlay.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return RealTimeAutoSyncWrapper(
      child: ConnectionLostOverlay(
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}
