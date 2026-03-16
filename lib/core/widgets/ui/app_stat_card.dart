import 'package:flutter/material.dart';

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (icon != null) ...[
              CircleAvatar(
                radius: 18,
                backgroundColor: (iconColor ?? colorScheme.primary).withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(label)),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
