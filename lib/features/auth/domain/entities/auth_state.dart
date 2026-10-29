import 'package:equatable/equatable.dart';
import 'user_entity.dart';

enum AuthStatus {
  loading,
  unauthenticated,
  authenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final bool hasSeenOnboarding;

  const AuthState({
    required this.status,
    this.user,
    this.hasSeenOnboarding = false,
  });

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  factory AuthState.unauthenticated({bool hasSeenOnboarding = false}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  factory AuthState.authenticated(UserEntity user, {bool hasSeenOnboarding = true}) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool? hasSeenOnboarding,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  @override
  List<Object?> get props => [status, user, hasSeenOnboarding];
}
