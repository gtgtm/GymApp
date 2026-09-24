import 'package:flutter/material.dart';

/// Asks before signing out; true only when the user confirms.
Future<bool> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to use GymBrain on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: const Text('Log out'),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
