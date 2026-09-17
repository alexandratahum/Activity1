import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/routes/app_routes.dart';
import 'package:portfolio_app/state/app_settings.dart';
import 'package:portfolio_app/state/network_models.dart';
import 'package:portfolio_app/state/network_monitor_service.dart';
import 'package:portfolio_app/widgets/activity_card.dart';
import 'package:portfolio_app/widgets/section_heading.dart';
import 'package:portfolio_app/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final networkMonitor = Provider.of<NetworkMonitorService>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Lab'),
        actions: [
          IconButton(
            tooltip: 'Open settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {
            final contentWidth = (constraints.maxWidth - 40)
                .clamp(0.0, 1040.0)
                .toDouble();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeHeader(
                        profileName: settings.profileName,
                        isDarkMode: settings.isDarkMode,
                      ),
                      const SizedBox(height: 24),
                      _DashboardPanels(
                        colorScheme: colorScheme,
                        profileName: settings.profileName,
                        availableWidth: contentWidth,
                        networkStatus: networkMonitor.status,
                        interfaceSummary: networkMonitor.interfaceSummary,
                      ),
                      const SizedBox(height: 28),
                      const SectionHeading(
                        title: 'Laboratory activities',
                        subtitle:
                            'Open an activity to explore navigation and local state.',
                      ),
                      const SizedBox(height: 12),
                      _ActivityPanels(
                        availableWidth: contentWidth,
                        context: context,
                      ),
                      const SizedBox(height: 28),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Your profile and theme preference are stored in global Provider state and update every screen immediately.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardPanels extends StatelessWidget {
  const _DashboardPanels({
    required this.colorScheme,
    required this.profileName,
    required this.availableWidth,
    required this.networkStatus,
    required this.interfaceSummary,
  });

  final ColorScheme colorScheme;
  final String profileName;
  final double availableWidth;
  final NetworkStatus networkStatus;
  final String interfaceSummary;

  @override
  Widget build(BuildContext context) {
    final summaryWidth = (availableWidth - 16) * 2 / 3;
    final progressWidth = (availableWidth - 16) / 3;

    Widget summaryCard() {
      return _SummaryCard(
        colorScheme: colorScheme,
        profileName: profileName,
        networkStatus: networkStatus,
        interfaceSummary: interfaceSummary,
      );
    }

    if (availableWidth >= 760) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: summaryWidth, child: summaryCard()),
          const SizedBox(width: 16),
          SizedBox(width: progressWidth, child: const _ProgressCard()),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(width: availableWidth, child: summaryCard()),
        const SizedBox(height: 16),
        SizedBox(width: availableWidth, child: const _ProgressCard()),
      ],
    );
  }
}

class _ActivityPanels extends StatelessWidget {
  const _ActivityPanels({required this.availableWidth, required this.context});

  final double availableWidth;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      ActivityCard(
        icon: Icons.touch_app_outlined,
        title: 'Counter Lab',
        description:
            'Practice StatefulWidget interactions and responsive controls.',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.activityOne),
      ),
      ActivityCard(
        icon: Icons.grid_view_outlined,
        title: 'Layout Explorer',
        description:
            'Compare responsive card layouts and local selection state.',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.activityTwo),
      ),
      ActivityCard(
        icon: Icons.wifi_find_outlined,
        title: 'Network Monitor',
        description:
            'Watch live connectivity and recover queued work automatically.',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.networkMonitor),
      ),
    ];

    if (availableWidth >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final card in cards) ...[
            Expanded(child: card),
            if (card != cards.last) const SizedBox(width: 16),
          ],
        ],
      );
    }

    if (availableWidth >= 680) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          cards[2],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < cards.length; index += 1) ...[
          cards[index],
          if (index < cards.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.profileName, required this.isDarkMode});

  final String profileName;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.school_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $profileName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                isDarkMode ? 'Dark theme is active' : 'Light theme is active',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.colorScheme,
    required this.profileName,
    required this.networkStatus,
    required this.interfaceSummary,
  });

  final ColorScheme colorScheme;
  final String profileName;
  final NetworkStatus networkStatus;
  final String interfaceSummary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Master compilation portfolio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Signed in as $profileName',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InputChip(
                  avatar: Icon(
                    Icons.navigate_next,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  label: const Text('Navigation ready'),
                  backgroundColor: colorScheme.primaryContainer,
                ),
                InputChip(
                  avatar: Icon(
                    Icons.palette_outlined,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  label: const Text('Theme connected'),
                  backgroundColor: colorScheme.primaryContainer,
                ),
                InputChip(
                  avatar: Icon(
                    _networkIcon(networkStatus),
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  label: Text('Network: ${networkStatus.label}'),
                  backgroundColor: colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Active interfaces: $interfaceSummary',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  IconData _networkIcon(NetworkStatus status) {
    return switch (status) {
      NetworkStatus.wifi => Icons.wifi,
      NetworkStatus.cellular => Icons.signal_cellular_alt,
      NetworkStatus.offline => Icons.wifi_off_outlined,
      NetworkStatus.other => Icons.dns_outlined,
      NetworkStatus.unknown => Icons.sync_outlined,
    };
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            const StatCard(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              value: 'Ready',
            ),
            const SizedBox(height: 12),
            const StatCard(
              icon: Icons.science_outlined,
              label: 'Activities',
              value: '3',
            ),
            const SizedBox(height: 12),
            const StatCard(
              icon: Icons.settings_outlined,
              label: 'Global state',
              value: 'Active',
            ),
          ],
        ),
      ),
    );
  }
}
