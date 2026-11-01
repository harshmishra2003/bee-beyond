import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'core/services/secure_storage_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void bootstrap(Widget Function() builder) {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher error: $error\n$stack');
    return true;
  };

  try {
    final secureStorage = SecureStorageService();
    final authInterceptor = AuthInterceptor(secureStorage);
    final loggingInterceptor = LoggingInterceptor();
    final dioClient = DioClient(
      authInterceptor: authInterceptor,
      loggingInterceptor: loggingInterceptor,
    );

    runApp(
      ProviderScope(
        overrides: [
          dioClientProvider.overrideWithValue(dioClient),
        ],
        child: builder(),
      ),
    );
  } catch (e, st) {
    debugPrint('Bootstrap failed: $e\n$st');
    runApp(_BootstrapErrorApp(error: e.toString(), stack: st.toString()));
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  final String error;
  final String stack;
  const _BootstrapErrorApp({required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Startup error:\n\n$error\n\n$stack',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
