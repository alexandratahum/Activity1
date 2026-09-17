import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:portfolio_app/state/network_models.dart';

typedef NetworkRequestTask =
    Future<void> Function(
      bool Function() isConnected,
      void Function(int completedChunks) onProgress,
    );

class NetworkConnectionLostException implements Exception {
  const NetworkConnectionLostException([
    this.message = 'Network connection lost',
  ]);

  final String message;

  @override
  String toString() => 'NetworkConnectionLostException: $message';
}

abstract class ConnectivityClient {
  Stream<List<ConnectivityResult>> get connectivityStream;

  Future<List<ConnectivityResult>> checkConnectivity();
}

class ConnectivityPlusClient implements ConnectivityClient {
  ConnectivityPlusClient({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }
}

enum RequestState { idle, running, queued, recovering, completed, failed }

extension RequestStateLabels on RequestState {
  String get label {
    switch (this) {
      case RequestState.idle:
        return 'Ready';
      case RequestState.running:
        return 'Running';
      case RequestState.queued:
        return 'Queued';
      case RequestState.recovering:
        return 'Recovering';
      case RequestState.completed:
        return 'Completed';
      case RequestState.failed:
        return 'Failed';
    }
  }
}

class PendingNetworkRequest {
  PendingNetworkRequest({
    required this.id,
    required this.label,
    required this.task,
    this.totalChunks = 12,
  });

  final String id;
  final String label;
  final NetworkRequestTask task;
  final int totalChunks;
  int completedChunks = 0;
  int attempts = 0;
  RequestState state = RequestState.idle;
  String message = 'Waiting to start';

  int get progressPercent {
    if (totalChunks <= 0) {
      return 0;
    }

    return (completedChunks * 100 / totalChunks).round();
  }
}

class NetworkMonitorService extends ChangeNotifier {
  NetworkMonitorService({
    ConnectivityClient? connectivityClient,
    NetworkRequestTask? requestTask,
    Duration stableConnectionDelay = const Duration(milliseconds: 600),
  }) : _connectivityClient = connectivityClient ?? ConnectivityPlusClient(),
       _requestTask = requestTask ?? _defaultRequestTask,
       _stableConnectionDelay = stableConnectionDelay;

  final ConnectivityClient _connectivityClient;
  final NetworkRequestTask _requestTask;
  final Duration _stableConnectionDelay;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  Future<void>? _activeTask;
  bool _initialized = false;
  bool _disposed = false;
  bool _retryInProgress = false;

  NetworkStatus _status = NetworkStatus.unknown;
  List<ConnectivityResult> _interfaces = const <ConnectivityResult>[];
  RequestState _requestState = RequestState.idle;
  PendingNetworkRequest? _activeRequest;
  PendingNetworkRequest? _lastRequest;
  final List<PendingNetworkRequest> _queuedRequests = [];
  final List<String> _eventLog = <String>['Monitoring connectivity stream'];

  NetworkStatus get status => _status;

  List<ConnectivityResult> get interfaces => _interfaces;

  bool get isOnline => _status.isConnected;

  RequestState get requestState => _requestState;

  PendingNetworkRequest? get activeRequest => _activeRequest;

  PendingNetworkRequest? get lastRequest => _lastRequest;

  List<PendingNetworkRequest> get queuedRequests =>
      List.unmodifiable(_queuedRequests);

  List<String> get eventLog => List.unmodifiable(_eventLog);

  String get activeInterfaceLabel => _status.label;

  String get interfaceSummary {
    if (_interfaces.isEmpty) {
      return 'Scanning interfaces';
    }

    return _interfaces.map(_interfaceLabel).toSet().join(' + ');
  }

  int get queuedRequestCount => _queuedRequests.length;

  Future<void> initialize() async {
    if (_initialized || _disposed) {
      return;
    }

    _initialized = true;
    _connectivitySubscription = _connectivityClient.connectivityStream.listen(
      _handleConnectivityChanged,
      onError: _handleConnectivityError,
    );

    try {
      final results = await _connectivityClient.checkConnectivity();
      _applyConnectivity(results, 'Initial connection check');
    } catch (error) {
      _applyConnectivity(const <ConnectivityResult>[
        ConnectivityResult.none,
      ], 'Connection check failed');
      _addEvent('Connectivity check error: ${_errorText(error)}');
    }
  }

  Future<void> startLargeDatasetRequest() async {
    if (_disposed ||
        _activeRequest != null ||
        _activeTask != null ||
        _requestState == RequestState.running ||
        _requestState == RequestState.recovering) {
      return;
    }

    if (_queuedRequests.isNotEmpty) {
      if (_status.isConnected) {
        await retryQueuedRequests();
      }
      return;
    }

    final request = PendingNetworkRequest(
      id: 'large-dataset',
      label: 'Large dataset sync',
      task: _requestTask,
    );
    _lastRequest = request;

    if (!_status.isConnected) {
      _queueRequest(request, 'Connection unavailable; request queued');
      return;
    }

    await _runRequest(request);
  }

  Future<void> retryQueuedRequests() async {
    if (_disposed ||
        _retryInProgress ||
        _activeRequest != null ||
        _activeTask != null ||
        _queuedRequests.isEmpty ||
        !_status.isConnected) {
      return;
    }

    _retryInProgress = true;
    _retryTimer?.cancel();
    _retryTimer = null;

    try {
      while (_queuedRequests.isNotEmpty && _status.isConnected && !_disposed) {
        final request = _queuedRequests.removeAt(0);
        request.completedChunks = 0;
        await _runRequest(request);

        if (_requestState == RequestState.queued) {
          break;
        }
      }
    } finally {
      _retryInProgress = false;
      _notifyListeners();
    }
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    _applyConnectivity(results, 'Connectivity stream update');
  }

  void _handleConnectivityError(Object error, StackTrace stackTrace) {
    _applyConnectivity(const <ConnectivityResult>[
      ConnectivityResult.none,
    ], 'Connectivity stream error');
    _addEvent('Connectivity stream error: ${_errorText(error)}');
  }

  void _applyConnectivity(List<ConnectivityResult> results, String source) {
    if (_disposed) {
      return;
    }

    final previousStatus = _status;
    final previousInterfaces = _interfaces;
    final snapshot = NetworkSnapshot.fromResults(results);
    _interfaces = snapshot.interfaces;
    _status = snapshot.status;

    if (!_status.isConnected) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _handleConnectionLoss('$source: connection lost');
    } else if (previousStatus == NetworkStatus.offline ||
        previousStatus == NetworkStatus.unknown) {
      if (_queuedRequests.isNotEmpty) {
        _scheduleRecovery('$source: ${_status.label} restored');
      } else {
        _requestState = RequestState.idle;
        _addEvent('$source: ${_status.label} restored');
      }
    } else if (previousStatus != NetworkStatus.unknown &&
        previousStatus != _status) {
      _handleHandover(
        '$source: handover from ${previousStatus.label} to ${_status.label}',
      );
    } else if (previousInterfaces.toString() != _interfaces.toString()) {
      _handleHandover('$source: active interfaces changed');
    } else {
      _addEvent('$source: ${_status.label}');
    }

    _notifyListeners();
  }

  void _handleConnectionLoss(String message) {
    _requestGeneration += 1;
    final activeRequest = _activeRequest;
    if (activeRequest != null) {
      _activeRequest = null;
      _queueRequest(activeRequest, message);
    } else {
      _requestState = _queuedRequests.isEmpty
          ? RequestState.idle
          : RequestState.queued;
      _lastRequest?.message = message;
      _addEvent(message);
    }
  }

  void _handleHandover(String message) {
    final activeRequest = _activeRequest;
    if (activeRequest != null) {
      _requestGeneration += 1;
      _activeRequest = null;
      _queueRequest(activeRequest, '$message; request queued for retry');
    } else {
      _addEvent(message);
    }

    if (_queuedRequests.isNotEmpty) {
      _scheduleRecovery('$message; retry scheduled');
    }
  }

  void _scheduleRecovery(String message) {
    _lastRequest?.message = message;
    _requestState = _queuedRequests.isEmpty
        ? RequestState.idle
        : RequestState.recovering;
    _addEvent(message);
    _retryTimer?.cancel();
    _retryTimer = Timer(_stableConnectionDelay, () {
      _retryTimer = null;
      retryQueuedRequests();
    });
  }

  Future<void> _runRequest(PendingNetworkRequest request) async {
    if (_disposed) {
      return;
    }

    final generation = _nextRequestGeneration();
    bool isConnected() {
      return !_disposed &&
          generation == _requestGeneration &&
          _activeRequest == request &&
          _status.isConnected;
    }

    void reportProgress(int completedChunks) {
      if (!isConnected()) {
        return;
      }

      request.completedChunks = completedChunks
          .clamp(0, request.totalChunks)
          .toInt();
      _notifyListeners();
    }

    _activeRequest = request;
    request.attempts += 1;
    request.completedChunks = 0;
    request.state = RequestState.running;
    request.message = 'Request running on ${_status.label}';
    _requestState = RequestState.running;
    _addEvent('Started ${request.label} on ${_status.label}');
    _notifyListeners();

    Future<void> task;
    try {
      task = request.task(isConnected, reportProgress);
    } catch (error) {
      _handleRequestFailure(request, error);
      _activeRequest = null;
      _notifyListeners();
      return;
    }

    _activeTask = task;
    try {
      await task;
      if (!isConnected()) {
        throw const NetworkConnectionLostException();
      }

      request.completedChunks = request.totalChunks;
      request.state = RequestState.completed;
      request.message = 'Request completed successfully';
      _activeRequest = null;
      _requestState = RequestState.completed;
      _addEvent('Completed ${request.label}');
    } catch (error) {
      _handleRequestFailure(request, error);
    } finally {
      if (identical(_activeTask, task)) {
        _activeTask = null;
      }
      if (_activeRequest == request) {
        _activeRequest = null;
      }
      if (_queuedRequests.isNotEmpty && _status.isConnected) {
        _scheduleRecovery('Connection stable; retry pending');
      }
      _notifyListeners();
    }
  }

  void _handleRequestFailure(PendingNetworkRequest request, Object error) {
    final connectionLost =
        error is NetworkConnectionLostException ||
        !_status.isConnected ||
        _activeRequest != request;
    if (connectionLost) {
      _queueRequest(
        request,
        'Connection interrupted; request queued for retry',
      );
    } else {
      request.state = RequestState.failed;
      request.message = 'Request failed: ${_errorText(error)}';
      _activeRequest = null;
      _requestState = RequestState.failed;
      _addEvent('Failed ${request.label}: ${_errorText(error)}');
    }
  }

  int _requestGeneration = 0;

  int _nextRequestGeneration() {
    _requestGeneration += 1;
    return _requestGeneration;
  }

  void _queueRequest(PendingNetworkRequest request, String message) {
    if (!_queuedRequests.any((queued) => queued.id == request.id)) {
      _queuedRequests.add(request);
    }

    request.state = RequestState.queued;
    request.message = message;
    _lastRequest = request;
    _requestState = RequestState.queued;
    _addEvent(message);
  }

  static Future<void> _defaultRequestTask(
    bool Function() isConnected,
    void Function(int completedChunks) onProgress,
  ) async {
    const totalChunks = 12;
    for (var chunk = 1; chunk <= totalChunks; chunk += 1) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!isConnected()) {
        throw const NetworkConnectionLostException();
      }
      onProgress(chunk);
    }
  }

  static String _interfaceLabel(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Cellular';
      case ConnectivityResult.none:
        return 'Offline';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.satellite:
        return 'Satellite';
      case ConnectivityResult.other:
        return 'Other';
    }
  }

  static String _errorText(Object error) {
    return error is NetworkConnectionLostException
        ? error.message
        : error.toString();
  }

  void _addEvent(String event) {
    _eventLog.insert(0, event);
    if (_eventLog.length > 8) {
      _eventLog.removeRange(8, _eventLog.length);
    }
  }

  void _notifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
