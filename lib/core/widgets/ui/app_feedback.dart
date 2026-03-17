import 'package:flutter/material.dart';

abstract final class AppFeedback {
  static SnackBar _snackBar(
    String message, {
    Color? backgroundColor,
    IconData? icon,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar(
        message,
        backgroundColor: Colors.green.shade700,
        icon: Icons.check_circle_outline,
      ),
    );
  }

  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar(
        message,
        backgroundColor: Colors.red.shade700,
        icon: Icons.error_outline,
      ),
    );
  }
}
