import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isPrimary = true,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final button = isPrimary
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
