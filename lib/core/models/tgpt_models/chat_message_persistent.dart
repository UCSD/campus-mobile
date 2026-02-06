import 'package:hive/hive.dart';

part 'chat_message_persistent.g.dart';

@HiveType(typeId: 3)
class ChatMessagePersistent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String authorId;

  @HiveField(3)
  final int createdAt;

  @HiveField(4)
  final bool isFromUser;

  @HiveField(5)
  final String? sessionId;

  ChatMessagePersistent({
    required this.id,
    required this.text,
    required this.authorId,
    required this.createdAt,
    required this.isFromUser,
    this.sessionId,
  });
}
