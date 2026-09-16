import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/state/app_settings.dart';
import 'package:portfolio_app/widgets/app_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global preferences',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Changes here are stored in Provider and appear throughout the app immediately.',
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile name',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: settings.setProfileName,
                              decoration: const InputDecoration(
                                labelText: 'Display name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SwitchListTile(
                              secondary: Icon(
                                settings.isDarkMode
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                              ),
                              title: const Text('Dark theme'),
                              subtitle: Text(
                                settings.isDarkMode
                                    ? 'Dark mode is active across all routes'
                                    : 'Light mode is active across all routes',
                              ),
                              value: settings.isDarkMode,
                              onChanged: settings.setDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Reset preferences',
                            icon: Icons.refresh,
                            outlined: true,
                            onPressed: settings.reset,
                          ),
                        ),
                      ],
                    ),
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
