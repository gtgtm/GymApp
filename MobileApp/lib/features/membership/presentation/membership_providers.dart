import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/membership/domain/membership_models.dart';

part 'membership_providers.g.dart';

@riverpod
Future<MemberProfile> memberProfile(Ref ref) {
  return ref.watch(membershipRepositoryProvider).profile();
}

@riverpod
Future<MembershipDetails> membershipDetails(Ref ref) {
  return ref.watch(membershipRepositoryProvider).membership();
}

@riverpod
Future<({String qrToken, String memberCode})> memberQrCode(Ref ref) {
  return ref.watch(membershipRepositoryProvider).qrCode();
}
