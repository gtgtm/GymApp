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
    // A login with exactly ONE membership is
    // auto-entered here too — no picker needed, matching this app's
    // behaviour from before multi-gym memberships existed. A login with
    // zero or several memberships is left unset: zero means nothing to
    // enter, several means the router sends them to MyGymsScreen to choose
    // explicitly (see app_router.dart).
    ref.listen(authControllerProvider, (_, next) {
      final user = next.value;
      if (user == null) {
        state = null;
        return;
      }

      final sole = user.soleMembership;
      if (sole != null) {
        enter(ActingGym(id: sole.gymId, name: sole.gymName));
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

/// The role that applies to the gym currently being acted as — the answer
/// to "what can this login do right now", which nav gating and dashboard
/// variants both need. It comes from whichever membership matches the
/// acting gym, or the sole membership if none has been explicitly entered
/// yet.
@riverpod
String? actingRoleName(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return null;

  final actingGym = ref.watch(actingGymControllerProvider);

  if (actingGym != null) {
    return user.membershipFor(actingGym.id)?.roleName;
  }

  return user.soleMembership?.roleName;
}
