import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { unknown, wifi, cellular, offline, other }

extension NetworkStatusLabels on NetworkStatus {
  String get label {
    switch (this) {
      case NetworkStatus.wifi:
        return 'Wi-Fi';
      case NetworkStatus.cellular:
        return 'Cellular';
      case NetworkStatus.offline:
        return 'Offline';
      case NetworkStatus.other:
        return 'Other network';
      case NetworkStatus.unknown:
        return 'Detecting';
    }
  }

  bool get isConnected {
    return this == NetworkStatus.wifi ||
        this == NetworkStatus.cellular ||
        this == NetworkStatus.other;
  }
}

class NetworkSnapshot {
  const NetworkSnapshot({required this.status, required this.interfaces});

  final NetworkStatus status;
  final List<ConnectivityResult> interfaces;

  factory NetworkSnapshot.fromResults(List<ConnectivityResult> results) {
    return NetworkSnapshot(
      status: _statusFromResults(results),
      interfaces: List.unmodifiable(results),
    );
  }

  static NetworkStatus _statusFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkStatus.wifi;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkStatus.cellular;
    }

    if (results.any((result) => result != ConnectivityResult.none)) {
      return NetworkStatus.other;
    }

    return NetworkStatus.offline;
  }
}
