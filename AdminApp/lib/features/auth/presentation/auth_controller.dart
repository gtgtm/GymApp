import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/auth/data/auth_repository.dart';
import 'package:gymapp_admin/features/auth/domain/staff_user.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<StaffUser?> build() async {
    ref.read(unauthorizedHubProvider).register(() {
      ref.read(actingGymHubProvider).clear();
      state = const AsyncData(null);
    });

    return ref.read(authRepositoryProvider).currentUser();
  }

  Future<void> login({required String email, required String password}) async {
    ref.read(actingGymHubProvider).clear();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .login(email: email, password: password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(actingGymHubProvider).clear();
    state = const AsyncData(null);
  }
}
