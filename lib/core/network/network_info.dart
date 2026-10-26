import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (_hasNoNetworkInterface(results)) {
        return false;
      }
      return await _checkInternetAccess();
    } catch (_) {
      return false;
    }
  }

  bool _hasNoNetworkInterface(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((result) => result == ConnectivityResult.none);
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    try {
      final result = await InternetAddress.lookup('1.1.1.1')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (_hasNoNetworkInterface(results)) {
        return false;
      }
      return await _checkInternetAccess();
    });
  }
}
