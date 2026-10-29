import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_info.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

class NetworkState {
  final bool isConnected;
  final bool isChecking;

  const NetworkState({
    required this.isConnected,
    this.isChecking = false,
  });

  NetworkState copyWith({
    bool? isConnected,
    bool? isChecking,
  }) {
    return NetworkState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class NetworkConnectivityNotifier extends StateNotifier<NetworkState> {
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;
  Timer? _periodicTimer;

  NetworkConnectivityNotifier(this._networkInfo)
      : super(const NetworkState(isConnected: true)) {
    _init();
  }

  void _init() {
    // Perform initial check
    checkConnection();

    // Listen to network changes
    _subscription = _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (state.isConnected != isConnected) {
        state = state.copyWith(isConnected: isConnected);
      }
    });

    // Heartbeat periodic check (every 4 seconds)
    _periodicTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await _checkSilently();
    });
  }

  Future<void> _checkSilently() async {
    final connected = await _networkInfo.isConnected;
    if (state.isConnected != connected) {
      state = state.copyWith(isConnected: connected);
    }
  }

  Future<bool> checkConnection() async {
    if (state.isChecking) return state.isConnected;
    state = state.copyWith(isChecking: true);
    final connected = await _networkInfo.isConnected;
    state = NetworkState(
      isConnected: connected,
      isChecking: false,
    );
    return connected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}

final networkConnectivityProvider =
    StateNotifierProvider<NetworkConnectivityNotifier, NetworkState>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return NetworkConnectivityNotifier(networkInfo);
});
