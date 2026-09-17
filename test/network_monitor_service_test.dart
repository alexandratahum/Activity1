import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/state/network_models.dart';
import 'package:portfolio_app/state/network_monitor_service.dart';

class FakeConnectivityClient implements ConnectivityClient {
  FakeConnectivityClient(this.initialResults);

  final List<ConnectivityResult> initialResults;
  final StreamController<List<ConnectivityResult>> controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get connectivityStream {
    return controller.stream;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() {
    return Future<List<ConnectivityResult>>.value(
      List<ConnectivityResult>.unmodifiable(initialResults),
    );
  }

  void emit(List<ConnectivityResult> results) {
    controller.add(results);
  }

  Future<void> dispose() {
    return controller.close();
  }
}

void main() {
  test(
    'queues work while offline and retries after a stable reconnection',
    () async {
      final client = FakeConnectivityClient(const <ConnectivityResult>[
        ConnectivityResult.none,
      ]);
      final service = NetworkMonitorService(
        connectivityClient: client,
        stableConnectionDelay: const Duration(milliseconds: 20),
        requestTask: (_, onProgress) async {
          onProgress(12);
        },
      );
      addTearDown(() {
        service.dispose();
        client.dispose();
      });

      await service.initialize();
      expect(service.status, NetworkStatus.offline);

      await service.startLargeDatasetRequest();
      expect(service.queuedRequestCount, 1);
      expect(service.lastRequest?.state, RequestState.queued);

      client.emit(const <ConnectivityResult>[ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(service.status, NetworkStatus.wifi);
      expect(service.queuedRequestCount, 0);
      expect(service.requestState, RequestState.completed);
      expect(service.lastRequest?.attempts, 1);
      expect(service.lastRequest?.progressPercent, 100);
    },
  );

  test(
    'invalidates an in-flight request during handover and retries it once',
    () async {
      final client = FakeConnectivityClient(const <ConnectivityResult>[
        ConnectivityResult.wifi,
      ]);
      final firstStarted = Completer<void>();
      final firstRelease = Completer<void>();
      final secondStarted = Completer<void>();
      var attempts = 0;
      late void Function(int) staleProgress;

      final service = NetworkMonitorService(
        connectivityClient: client,
        stableConnectionDelay: const Duration(milliseconds: 20),
        requestTask: (isConnected, onProgress) async {
          attempts += 1;
          if (attempts == 1) {
            staleProgress = onProgress;
            firstStarted.complete();
            await firstRelease.future;
            if (!isConnected()) {
              throw const NetworkConnectionLostException();
            }
            onProgress(12);
          } else {
            secondStarted.complete();
            onProgress(12);
          }
        },
      );
      addTearDown(() {
        service.dispose();
        client.dispose();
      });

      await service.initialize();
      final start = service.startLargeDatasetRequest();
      await firstStarted.future;

      staleProgress(3);
      expect(service.lastRequest?.progressPercent, 25);

      client.emit(const <ConnectivityResult>[ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);
      expect(service.queuedRequestCount, 1);
      expect(service.activeRequest, isNull);

      staleProgress(6);
      expect(service.lastRequest?.progressPercent, 25);

      firstRelease.complete();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(secondStarted.isCompleted, isTrue);
      expect(service.queuedRequestCount, 0);
      expect(service.requestState, RequestState.completed);
      expect(service.lastRequest?.attempts, 2);
      expect(service.lastRequest?.progressPercent, 100);
      await start;
    },
  );
}
