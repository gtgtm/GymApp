import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_exception.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/core/auth/token_storage.dart';
import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';
import 'package:gymapp_admin/features/auth/domain/staff_user.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<StaffUser> login({
    required String email,
    required String password,
  }) async {
    final result = await unwrap(
      () => _apiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      ),
      (data) => data as Map<String, dynamic>,
    );

    final token = result['token'] as String;
    // /login returns `memberships` alongside `user` (unlike /me, which nests
    // it inside the user object) — merge it in so StaffUser sees them.
    final user = StaffUser.fromJson({
      ...result['user'] as Map<String, dynamic>,
      'memberships': result['memberships'] ?? const [],
    });

    if (user.isSuperAdmin) {
      throw const ApiException(
        'Platform owner accounts are not supported here. Use the GymBrain web dashboard.',
      );
    }

    if (!_hasStaffAccess(user)) {
      // Do not persist a token for an account this app doesn't support —
      // member-only accounts belong in the member portal app instead.
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

      if (!_hasStaffAccess(user)) {
        await _tokenStorage.clear();
        return null;
      }

      return user;
    } on Exception {
      await _tokenStorage.clear();
      return null;
    }
  }

  /// The caller's ACTIVE memberships — the gyms they can act as right now.
  Future<List<GymMembership>> myGyms() {
    return unwrap(
      () => _apiClient.dio.get('/my-gyms'),
      (data) => (data as List<dynamic>)
          .map((json) => GymMembership.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Memberships another gym added this person to by email, awaiting their
  /// own confirmation (see GymMembershipService on the backend) before
  /// that gym can act on their behalf.
  Future<List<GymMembership>> pendingGyms() {
    return unwrap(
      () => _apiClient.dio.get('/my-gyms/pending'),
      (data) => (data as List<dynamic>)
          .map((json) => GymMembership.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<GymMembership> acceptMembership(int membershipId) {
    return unwrap(
      () => _apiClient.dio.post('/memberships/$membershipId/accept'),
      (data) => GymMembership.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Records which gym to pre-select next login. Purely a UX convenience —
  /// it does NOT scope this session; the caller must still enter the gym
  /// via ActingGymController so ApiClient attaches X-Gym-Id on every
  /// subsequent request.
  Future<GymMembership> switchGym(int gymId) {
    return unwrap(
      () => _apiClient.dio.post('/switch-gym', data: {'gym_id': gymId}),
      (data) => GymMembership.fromJson(data as Map<String, dynamic>),
    );
  }

  /// True when this login can use the staff app at all: it has at least one
  /// membership in a staff role (see nav_permissions.dart's
  /// staffRoleNames). A person who is ONLY a member everywhere they belong
  /// must use the member portal app instead — but a membership-list is not
  /// "one role" any more, so this checks each membership rather than a
  /// single top-level roleName.
  bool _hasStaffAccess(StaffUser user) {
    return user.memberships.any(
      (membership) => staffRoleNames.contains(membership.roleName),
    );
  }
}
