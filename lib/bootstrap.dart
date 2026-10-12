import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'core/services/secure_storage_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

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
}
