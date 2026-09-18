import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/acting_gym.dart';
import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';

part 'acting_gym_controller.g.dart';

/// Riverpod-visible mirror of ActingGymHub so widgets can watch/rebuild on
/// enter/exit. ApiClient reads the hub directly (it can't depend on
/// Riverpod), so every mutation here must also update the hub.
@Riverpod(keepAlive: true)
class ActingGymController extends _$ActingGymController {
  @override
  ActingGym? build() {
    // Login/logout/401 all clear ActingGymHub (see AuthController); mirror
    // that here so this state and the header ApiClient sends never drift.
    ref.listen(authControllerProvider, (_, next) {
      if (next.value == null) {
        state = null;
      }
    });

    return null;
  }

  void enter(ActingGym gym) {
    ref.read(actingGymHubProvider).set(gym);
    state = gym;
  }

  void exit() {
    ref.read(actingGymHubProvider).clear();
    state = null;
  }
}
