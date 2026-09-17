import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/state/network_models.dart';
import 'package:portfolio_app/state/network_monitor_service.dart';

class NetworkMonitorScreen extends StatelessWidget {
  const NetworkMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monitor = Provider.of<NetworkMonitorService>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final request = monitor.activeRequest ?? monitor.lastRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Monitor'),
        actions: [
          IconButton(
            tooltip: 'Retry queued requests',
            onPressed: monitor.retryQueuedRequests,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live connectivity',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectivity Plus reports the active interface while queued work waits for a stable connection.',
                    ),
                    const SizedBox(height: 20),
                    _StatusCard(monitor: monitor, colorScheme: colorScheme),
                    const SizedBox(height: 16),
                    _InterfaceStrip(monitor: monitor, colorScheme: colorScheme),
                    const SizedBox(height: 20),
                    _RequestCard(
                      monitor: monitor,
                      request: request,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 20),
                    _EventLog(monitor: monitor, colorScheme: colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.monitor, required this.colorScheme});

  final NetworkMonitorService monitor;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(monitor.status, colorScheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: statusColor,
              child: Icon(
                _statusIcon(monitor.status),
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monitor.activeInterfaceLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monitor.interfaceSummary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  InputChip(
                    avatar: Icon(
                      monitor.isOnline
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    label: Text(
                      monitor.isOnline
                          ? 'Connection available'
                          : 'Connection unavailable',
                    ),
                    backgroundColor: colorScheme.primaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(NetworkStatus status, ColorScheme scheme) {
    return switch (status) {
      NetworkStatus.wifi => Colors.green,
      NetworkStatus.cellular => Colors.amber,
      NetworkStatus.offline => Colors.red,
      NetworkStatus.other => Colors.blue,
      NetworkStatus.unknown => scheme.primary,
    };
  }

  IconData _statusIcon(NetworkStatus status) {
    return switch (status) {
      NetworkStatus.wifi => Icons.wifi,
      NetworkStatus.cellular => Icons.signal_cellular_alt,
      NetworkStatus.offline => Icons.wifi_off_outlined,
      NetworkStatus.other => Icons.dns_outlined,
      NetworkStatus.unknown => Icons.sync_outlined,
    };
  }
}

class _InterfaceStrip extends StatelessWidget {
  const _InterfaceStrip({required this.monitor, required this.colorScheme});

  final NetworkMonitorService monitor;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detected interfaces',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InterfaceTile(
                    icon: Icons.wifi,
                    label: 'Wi-Fi',
                    active: monitor.interfaces.contains(
                      ConnectivityResult.wifi,
                    ),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InterfaceTile(
                    icon: Icons.signal_cellular_alt,
                    label: 'Cellular',
                    active: monitor.interfaces.contains(
                      ConnectivityResult.mobile,
                    ),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InterfaceTile(
                    icon: Icons.wifi_off_outlined,
                    label: 'Offline',
                    active: monitor.status == NetworkStatus.offline,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InterfaceTile extends StatelessWidget {
  const _InterfaceTile({
    required this.icon,
    required this.label,
    required this.active,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final bool active;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: active
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: active
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.monitor,
    required this.request,
    required this.colorScheme,
  });

  final NetworkMonitorService monitor;
  final PendingNetworkRequest? request;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final progress = request?.progressPercent ?? 0;
    final hasWork = monitor.queuedRequestCount > 0 || request != null;
    final isBusy =
        monitor.requestState == RequestState.running ||
        monitor.requestState == RequestState.recovering;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.sync_alt_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulated request queue',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasWork
                            ? '${monitor.queuedRequestCount} queued · ${monitor.requestState.label}'
                            : 'No requests waiting',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (request != null) ...[
              Text(
                request!.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress / 100),
              const SizedBox(height: 8),
              Text(
                '${request!.message} · ${request!.progressPercent}% · attempt ${request!.attempts}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : monitor.startLargeDatasetRequest,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      isBusy
                          ? 'Sync in progress'
                          : monitor.queuedRequestCount > 0
                          ? 'Retry queued requests'
                          : 'Start large dataset sync',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventLog extends StatelessWidget {
  const _EventLog({required this.monitor, required this.colorScheme});

  final NetworkMonitorService monitor;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemCount: monitor.eventLog.length,
              itemBuilder: (_, index) {
                final event = monitor.eventLog[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 7, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(event),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
