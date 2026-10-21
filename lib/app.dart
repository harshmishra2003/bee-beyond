import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/services/auto_data_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

class BeeBeyondApp extends ConsumerWidget {
  const BeeBeyondApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return RealTimeAutoSyncWrapper(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
