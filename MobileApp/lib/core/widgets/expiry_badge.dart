import 'package:flutter/material.dart';

import 'package:gymapp_member/core/widgets/status_badge.dart';
import 'package:gymapp_member/features/membership/domain/membership_models.dart';

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
    };

    return StatusBadge(label: label, tone: tone);
  }
}
