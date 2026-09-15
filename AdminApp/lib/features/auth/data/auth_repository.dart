import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_exception.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/core/auth/token_storage.dart';
import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/features/auth/domain/staff_user.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient, required TokenStorage tokenStorage})
      : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<StaffUser> login({required String email, required String password}) async {
    final result = await unwrap(
      () => _apiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      ),
      (data) => data as Map<String, dynamic>,
    );

    final token = result['token'] as String;
    final user = StaffUser.fromJson(result['user'] as Map<String, dynamic>);

    if (!staffRoleNames.contains(user.roleName)) {
      // Do not persist a token for an account this app doesn't support —
      // member accounts belong in the member portal app instead.
      throw const ApiException(
        'This app is for gym staff. Members should use the GymBrain member app.',
      );
    }

    await _tokenStorage.write(token);
    return user;
  }

  Future<void> logout() async {
    try {
      await unwrap(() => _apiClient.dio.post('/logout'), (_) => null);
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<StaffUser?> currentUser() async {
    final token = await _tokenStorage.read();
    if (token == null) return null;

    try {
      final user = await unwrap(
        () => _apiClient.dio.get('/me'),
        (data) => StaffUser.fromJson(data as Map<String, dynamic>),
      );

      if (!staffRoleNames.contains(user.roleName)) {
        await _tokenStorage.clear();
        return null;
      }

      return user;
    } on Exception {
      await _tokenStorage.clear();
      return null;
    }
  }
}
