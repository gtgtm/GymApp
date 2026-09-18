import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/router/app_router.dart';
import 'package:gymapp_admin/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: GymBrainStaff()));
}

class GymBrainStaff extends ConsumerWidget {
  const GymBrainStaff({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'GymBrain Staff',
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
