import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const SizedBox(width: 8), Icon(icon, size: 18)],
      ),
    );

    if (outlined) {
      return OutlinedButton(onPressed: onPressed, child: child);
    }

    return FilledButton(onPressed: onPressed, child: child);
  }
}
