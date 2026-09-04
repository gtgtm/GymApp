import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_member/core/router/app_router.dart';
import 'package:gymapp_member/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: GymAppMember()));
}

class GymAppMember extends ConsumerWidget {
  const GymAppMember({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'GymApp Member',
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
