import 'package:hive/hive.dart';

part 'chat_message_persistent.g.dart';

/// Persistent chat message model for local storage via Hive.
/// 
/// This model stores chat messages locally for viewing chat history
/// when offline or for quick access without API calls.
@HiveType(typeId: 3)
class ChatMessagePersistent extends HiveObject {
  /// Unique identifier for this message
  @HiveField(0)
  final String id;

  /// The message text content
  @HiveField(1)
  final String text;

  /// Author identifier (user PID or assistant ID)
  @HiveField(2)
  final String authorId;

  /// Unix timestamp (milliseconds since epoch) when message was created
  @HiveField(3)
  final int createdAt;

  /// True if this message is from the user, false if from assistant
  @HiveField(4)
  final bool isFromUser;

  /// The chat session ID this message belongs to
  @HiveField(5)
  final String? sessionId;

  /// Parent message ID for threading (null for first message)
  @HiveField(6)
  final String? parentMessageId;

  ChatMessagePersistent({
    required this.id,
    required this.text,
    required this.authorId,
    required this.createdAt,
    required this.isFromUser,
    this.sessionId,
    this.parentMessageId,
  });

  /// Create a ChatMessagePersistent from JSON
  factory ChatMessagePersistent.fromJson(Map<String, dynamic> json) => ChatMessagePersistent(
        id: json["id"],
        text: json["text"],
        authorId: json["author_id"] ?? json["authorId"],
        createdAt: json["created_at"] ?? json["createdAt"],
        isFromUser: json["is_from_user"] ?? json["isFromUser"],
        sessionId: json["session_id"] ?? json["sessionId"],
        parentMessageId: json["parent_message_id"] ?? json["parentMessageId"],
      );

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "author_id": authorId,
        "created_at": createdAt,
        "is_from_user": isFromUser,
        "session_id": sessionId,
        "parent_message_id": parentMessageId,
      };
}
