import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';

part 'member_providers.g.dart';

@riverpod
Future<MemberListPage> memberList(Ref ref, String search) {
  return ref.watch(memberRepositoryProvider).list(search: search);
}

@riverpod
Future<Member> memberDetail(Ref ref, int id) {
  return ref.watch(memberRepositoryProvider).show(id);
}

@riverpod
Future<List<MemberPayment>> memberPayments(Ref ref, int id) {
  return ref.watch(memberRepositoryProvider).payments(id);
}
