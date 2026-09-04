import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/membership/domain/membership_models.dart';

class MembershipRepository {
  MembershipRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberProfile> profile() {
    return unwrap(
      () => _apiClient.dio.get('/me/profile'),
      (data) => MemberProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<MembershipDetails> membership() {
    return unwrap(
      () => _apiClient.dio.get('/me/membership'),
      (data) => MembershipDetails.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> requestRenewal() {
    return unwrap(
      () => _apiClient.dio.post('/me/membership/request-renewal'),
      (_) => null,
    );
  }

  Future<({String qrToken, String memberCode})> qrCode() {
    return unwrap(
      () => _apiClient.dio.get('/me/qr-code'),
      (data) {
        final map = data as Map<String, dynamic>;
        return (qrToken: map['qr_token'] as String, memberCode: map['member_code'] as String);
      },
    );
  }
}
