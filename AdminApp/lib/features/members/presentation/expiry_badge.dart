import 'package:flutter/material.dart';

import 'package:gymapp_admin/core/widgets/status_badge.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';

class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({required this.bucket, super.key});

  final ExpiryBucket bucket;

  @override
  Widget build(BuildContext context) {
    final (tone, label) = switch (bucket) {
      ExpiryBucket.green => (StatusTone.success, 'Active'),
      ExpiryBucket.yellow => (StatusTone.warning, 'Expiring soon'),
      ExpiryBucket.orange => (StatusTone.warning, 'Expiring soon'),
      ExpiryBucket.red => (StatusTone.danger, 'Expired'),
      ExpiryBucket.unknown => (StatusTone.neutral, 'Unknown'),
    };

    return StatusBadge(label: label, tone: tone);
  }
}
