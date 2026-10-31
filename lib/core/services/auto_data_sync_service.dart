import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/courses/presentation/providers/course_provider.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/workshops/presentation/providers/workshop_provider.dart';
import '../../features/membership/presentation/providers/membership_provider.dart';
import '../../features/orders/presentation/providers/order_provider.dart';
import '../../features/products/presentation/providers/product_provider.dart';
import '../../features/services/presentation/providers/services_provider.dart';

/// Live Auto-Sync Status State
class AutoSyncStatus {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final bool isForegroundActive;

  const AutoSyncStatus({
    this.isSyncing = false,
    this.lastSyncTime,
    this.isForegroundActive = true,
  });

  AutoSyncStatus copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    bool? isForegroundActive,
  }) {
    return AutoSyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isForegroundActive: isForegroundActive ?? this.isForegroundActive,
    );
  }
}

final autoSyncStatusProvider =
    StateNotifierProvider<AutoSyncStatusNotifier, AutoSyncStatus>((ref) {
  return AutoSyncStatusNotifier();
});

class AutoSyncStatusNotifier extends StateNotifier<AutoSyncStatus> {
  AutoSyncStatusNotifier() : super(const AutoSyncStatus());

  void setSyncing(bool syncing) {
    state = state.copyWith(
      isSyncing: syncing,
      lastSyncTime: syncing ? state.lastSyncTime : DateTime.now(),
    );
  }

  void setForegroundStatus(bool active) {
    state = state.copyWith(isForegroundActive: active);
  }
}

/// Centralized Real-Time Background Data Auto-Sync Manager
/// Automatically polls and silently refreshes all non-auth app data providers
/// in the background without interrupting UI or flickering screens.
class AutoDataSyncService with WidgetsBindingObserver {
  final WidgetRef ref;
  Timer? _syncTimer;
  bool _isSyncing = false;

  AutoDataSyncService(this.ref) {
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicSync();
  }

  /// Start background polling every 20 seconds
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      syncAllDataSilently();
    });
  }

  /// Stop polling when app goes to background
  void stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    try {
      ref.read(autoSyncStatusProvider.notifier).setForegroundStatus(false);
    } catch (_) {}
  }

  /// App Lifecycle Interceptor: Resume sync when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(autoSyncStatusProvider.notifier).setForegroundStatus(true);
      _startPeriodicSync();
      syncAllDataSilently(); // Immediate silent background sync on foreground resume
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      stopSync();
    }
  }

  /// Silently refresh all non-auth data providers in the background
  Future<void> syncAllDataSilently() async {
    if (_isSyncing) return;
    _isSyncing = true;
    ref.read(autoSyncStatusProvider.notifier).setSyncing(true);

    try {
      // 1. Refresh Home Dashboard (Categories & Banners)
      ref.invalidate(homeDataProvider);

      // 2. Refresh Courses Data
      ref.invalidate(allCoursesProvider);

      // 3. Refresh Workshops & Masterclasses
      ref.invalidate(allWorkshopsProvider);

      // 4. Refresh E-Commerce Products
      ref.invalidate(allProductsProvider);

      // 5. Refresh Services
      ref.invalidate(servicesProvider);

      // 6. Refresh VIP Membership Plans
      ref.invalidate(membershipPlansProvider);

      // 7. Refresh Orders
      ref.invalidate(ordersListProvider);
    } catch (_) {
      // Background sync errors are silently swallowed so user UI is never interrupted
    } finally {
      _isSyncing = false;
      ref.read(autoSyncStatusProvider.notifier).setSyncing(false);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopSync();
  }
}

/// StatefulWidget wrapper that initializes and maintains the real-time background sync lifecycle.
class RealTimeAutoSyncWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const RealTimeAutoSyncWrapper({super.key, required this.child});

  @override
  ConsumerState<RealTimeAutoSyncWrapper> createState() => _RealTimeAutoSyncWrapperState();
}

class _RealTimeAutoSyncWrapperState extends ConsumerState<RealTimeAutoSyncWrapper> {
  AutoDataSyncService? _syncService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncService = AutoDataSyncService(ref);
      }
    });
  }

  @override
  void dispose() {
    _syncService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
