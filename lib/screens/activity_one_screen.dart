import 'package:flutter/material.dart';

class ActivityOneScreen extends StatefulWidget {
  const ActivityOneScreen({super.key});

  @override
  State<ActivityOneScreen> createState() => _ActivityOneScreenState();
}

class _ActivityOneScreenState extends State<ActivityOneScreen> {
  int _counter = 0;

  void _changeCounter(int delta) {
    setState(() {
      _counter += delta;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Lab')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Local screen state',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This interaction stays inside the activity screen. Return home to see that the dashboard remains unchanged.',
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final counterCard = Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 42,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  '$_counter',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'button taps',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                        final controlsCard = Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Controls',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Use the buttons to update this screen-specific value.',
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () => _changeCounter(1),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Increment'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _changeCounter(-1),
                                      icon: const Icon(Icons.remove),
                                      label: const Text('Decrement'),
                                    ),
                                    TextButton.icon(
                                      onPressed: _resetCounter,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reset'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );

                        if (constraints.maxWidth >= 700) {
                          return SizedBox(
                            height: 320,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: counterCard),
                                const SizedBox(width: 16),
                                Flexible(child: controlsCard),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 280, child: counterCard),
                            const SizedBox(height: 16),
                            controlsCard,
                          ],
                        );
                      },
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
