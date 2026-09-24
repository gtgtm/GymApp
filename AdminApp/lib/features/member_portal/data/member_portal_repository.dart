import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';

/// The member's own records. The backend resolves the member from the
/// token + acting gym (never from an id in the request), so none of these
/// take an id.
class MemberPortalRepository {
  MemberPortalRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberProfile> profile() =>
      _getObject('/me/profile', MemberProfile.fromJson);

  Future<MembershipDetails> membership() =>
      _getObject('/me/membership', MembershipDetails.fromJson);

  Future<MemberQrCode> qrCode() =>
      _getObject('/me/qr-code', MemberQrCode.fromJson);

  Future<PortalProgress> progress() =>
      _getObject('/me/progress', PortalProgress.fromJson);

  Future<List<MemberAttendanceRecord>> attendance() =>
      _getList('/me/attendance', MemberAttendanceRecord.fromJson);

  Future<List<MemberPaymentRecord>> payments() =>
      _getList('/me/payments', MemberPaymentRecord.fromJson);

  Future<List<MemberNotification>> notifications() =>
      _getList('/me/notifications', MemberNotification.fromJson);

  Future<List<PortalWorkoutPlan>> workoutPlans() =>
      _getList('/me/workout-plans', PortalWorkoutPlan.fromJson);

  Future<List<PortalDietPlan>> dietPlans() =>
      _getList('/me/diet-plans', PortalDietPlan.fromJson);

  /// Notifies the gym's admins and receptionists; staff process the
  /// renewal itself.
  Future<void> requestRenewal() => unwrap(
    () => _apiClient.dio.post('/me/membership/request-renewal'),
    (_) {},
  );

  Future<T> _getObject<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return unwrap(
      () => _apiClient.dio.get(path),
      (data) => fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return unwrap(
      () => _apiClient.dio.get(path),
      (data) => List<T>.unmodifiable([
        for (final item in data as List<dynamic>)
          fromJson(item as Map<String, dynamic>),
      ]),
    );
  }
}
