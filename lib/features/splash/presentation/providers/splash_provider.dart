import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initialization state provider for Splash screen loading sequence.
final splashInitializationProvider = FutureProvider.autoDispose<void>((ref) async {
  // Preload any essential assets or warm-up tasks if needed
  await Future.delayed(const Duration(milliseconds: 800));
});
