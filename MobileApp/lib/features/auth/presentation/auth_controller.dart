import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/api_providers.dart';
import 'package:gymapp_member/features/auth/data/auth_repository.dart';
import 'package:gymapp_member/features/auth/domain/member_user.dart';

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
  Future<MemberUser?> build() async {
    ref.read(unauthorizedHubProvider).register(() {
      state = const AsyncData(null);
    });

    return ref.read(authRepositoryProvider).currentUser();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email: email, password: password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
