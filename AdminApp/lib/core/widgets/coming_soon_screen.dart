import 'package:flutter/material.dart';

/// Placeholder for nav destinations not yet built in the current phase.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('$label is coming soon.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
