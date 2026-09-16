import 'package:flutter/material.dart';

class ActivityTwoScreen extends StatefulWidget {
  const ActivityTwoScreen({super.key});

  @override
  State<ActivityTwoScreen> createState() => _ActivityTwoScreenState();
}

class _ActivityTwoScreenState extends State<ActivityTwoScreen> {
  bool _showDetails = true;
  int _selectedIndex = 0;

  final List<_LayoutItem> _items = const [
    _LayoutItem(
      icon: Icons.view_agenda_outlined,
      title: 'Dashboard',
      detail: 'A responsive menu for every laboratory activity.',
    ),
    _LayoutItem(
      icon: Icons.animation,
      title: 'Widgets',
      detail: 'Declarative components built from native Flutter layouts.',
    ),
    _LayoutItem(
      icon: Icons.storage_outlined,
      title: 'Provider',
      detail: 'Shared state that stays synchronized across routes.',
    ),
    _LayoutItem(
      icon: Icons.phone_iphone,
      title: 'Devices',
      detail: 'A layout that adapts from phones to wide desktop windows.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Layout Explorer')),
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
                      'Responsive card grid',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a card to update local state. The layout changes its column count as space allows.',
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune_outlined),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Show activity details'),
                            ),
                            Switch(
                              value: _showDetails,
                              onChanged: (value) {
                                setState(() {
                                  _showDetails = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final cardWidth = _cardWidth(constraints.maxWidth);
                        final cards = List<Widget>.generate(
                          _items.length,
                          (index) => _LayoutCard(
                            item: _items[index],
                            isSelected: _selectedIndex == index,
                            showDetails: _showDetails,
                            width: cardWidth,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        );

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: cards,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selected: ${_items[_selectedIndex].title}',
                                style: Theme.of(context).textTheme.bodyMedium,
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
          ),
        ),
      ),
    );
  }

  double _cardWidth(double availableWidth) {
    if (availableWidth >= 860) {
      return (availableWidth - 32) / 3;
    }

    if (availableWidth >= 520) {
      return (availableWidth - 16) / 2;
    }

    return availableWidth;
  }
}

class _LayoutItem {
  const _LayoutItem({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;
}

class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.item,
    required this.isSelected,
    required this.showDetails,
    required this.width,
    required this.onTap,
  });

  final _LayoutItem item;
  final bool isSelected;
  final bool showDetails;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isSelected
                          ? colorScheme.primary
                          : colorScheme.primaryContainer,
                      child: Icon(
                        item.icon,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (showDetails) ...[
                  const SizedBox(height: 12),
                  Text(item.detail),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
