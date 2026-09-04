import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/core/auth/token_storage.dart';
import 'package:gymapp_member/features/auth/domain/member_user.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient, required TokenStorage tokenStorage})
      : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<MemberUser> login({required String email, required String password}) async {
    final result = await unwrap(
      () => _apiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      ),
      (data) => data as Map<String, dynamic>,
    );

    final token = result['token'] as String;
    await _tokenStorage.write(token);

    return MemberUser.fromJson(result['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await unwrap(() => _apiClient.dio.post('/logout'), (_) => null);
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<MemberUser?> currentUser() async {
    final token = await _tokenStorage.read();
    if (token == null) return null;

    try {
      return await unwrap(
        () => _apiClient.dio.get('/me'),
        (data) => MemberUser.fromJson(data as Map<String, dynamic>),
      );
    } on Exception {
      await _tokenStorage.clear();
      return null;
    }
  }
}
