import 'package:flutter/material.dart';

import 'package:gymapp_admin/features/members/domain/member_models.dart';

class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({required this.bucket, super.key});

  final ExpiryBucket bucket;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (bucket) {
      ExpiryBucket.green => (Colors.green, 'Active'),
      ExpiryBucket.yellow => (Colors.amber, 'Expiring soon'),
      ExpiryBucket.orange => (Colors.orange, 'Expiring soon'),
      ExpiryBucket.red => (Colors.red, 'Expired'),
      ExpiryBucket.unknown => (Colors.grey, 'Unknown'),
    };

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
