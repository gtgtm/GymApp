import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/notifications/data/notification_models.dart';

part 'notifications_providers.g.dart';

@riverpod
Future<List<MemberNotification>> myNotifications(Ref ref) {
  return ref.watch(notificationRepositoryProvider).myNotifications();
}
