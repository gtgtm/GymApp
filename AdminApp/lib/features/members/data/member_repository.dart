import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';

class MemberRepository {
  MemberRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberListPage> list({String? search}) {
    return unwrap(
      () => _apiClient.dio.get(
        '/members',
        queryParameters: {if (search != null && search.isNotEmpty) 'search': search},
      ),
      (data) {
        final items = (data as List<dynamic>)
            .map((json) => Member.fromJson(json as Map<String, dynamic>))
            .toList();
        return MemberListPage(members: items, total: items.length);
      },
    );
  }

  Future<Member> show(int id) {
    return unwrap(
      () => _apiClient.dio.get('/members/$id'),
      (data) => Member.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Member> create(MemberInput input) {
    return unwrap(
      () => _apiClient.dio.post('/members', data: input.toJson()),
      (data) => Member.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Member> update(int id, MemberInput input) {
    return unwrap(
      () => _apiClient.dio.put('/members/$id', data: input.toJson()),
      (data) => Member.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<MemberPayment>> payments(int id) {
    return unwrap(
      () => _apiClient.dio.get('/members/$id/payments'),
      (data) => (data as List<dynamic>)
          .map((json) => MemberPayment.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> renew(int id, RenewMembershipInput input) {
    return unwrap(
      () => _apiClient.dio.post('/members/$id/renew', data: input.toJson()),
      (_) => null,
    );
  }
}
