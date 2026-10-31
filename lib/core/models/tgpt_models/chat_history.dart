/// Session-index model for sidebar display (matches original cma-tgpt).
///
/// Represents a single chat session's metadata for listing in the sidebar.
/// Used by ChatPersistenceService to store/load session index.
class ChatSessionMeta {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSessionMeta({required this.id, required this.title, required this.createdAt, required this.updatedAt});

  ChatSessionMeta copyWith({String? title, DateTime? updatedAt}) {
    return ChatSessionMeta(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static ChatSessionMeta fromJson(Map<String, dynamic> j) => ChatSessionMeta(
    id: j['id'],
    title: j['title'],
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
  );
}
