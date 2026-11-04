import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/powered_by_tagline.dart';
import 'routing/app_router.dart';

class BeeBeyondApp extends ConsumerWidget {
  const BeeBeyondApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[BOOT] 7. BeeBeyondApp.build() executed at ${DateTime.now().toIso8601String()}');
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        debugPrint('[BOOT] 8. MaterialApp.builder executed at ${DateTime.now().toIso8601String()}');
        return Column(
          children: [
            Expanded(child: child ?? const SizedBox()),
            const PoweredByTagline(),
          ],
        );
      },
    );
  }
}
