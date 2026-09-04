import 'package:flutter/material.dart';

import 'package:gymapp_member/features/membership/domain/membership_models.dart';

class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({required this.bucket, super.key});

  final ExpiryBucket bucket;

  (Color, Color, String) _style() {
    return switch (bucket) {
      ExpiryBucket.green => (const Color(0xFFDCFCE7), const Color(0xFF15803D), 'Active'),
      ExpiryBucket.yellow => (const Color(0xFFFEF9C3), const Color(0xFFA16207), 'Expiring soon'),
      ExpiryBucket.orange => (const Color(0xFFFFEDD5), const Color(0xFFC2410C), 'Expiring soon'),
      ExpiryBucket.red => (const Color(0xFFFEE2E2), const Color(0xFFB91C1C), 'Expired'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = _style();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
