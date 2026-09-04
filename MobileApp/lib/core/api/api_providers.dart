import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/auth/token_storage.dart';

part 'api_providers.g.dart';

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => TokenStorage();

/// A callback the auth feature registers so the API client can notify it
/// when any request comes back 401 (e.g. token expired or revoked),
/// without api_client depending on the auth feature directly.
class UnauthorizedNotifier {
  UnauthorizedCallback? _callback;

  void register(UnauthorizedCallback callback) => _callback = callback;

  void notify() => _callback?.call();
}

@Riverpod(keepAlive: true)
UnauthorizedNotifier unauthorizedHub(Ref ref) => UnauthorizedNotifier();

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    onUnauthorized: () => ref.read(unauthorizedHubProvider).notify(),
  );
}
