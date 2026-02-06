import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message_persistent.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';

class ChatPersistenceService {
  static const String CHAT_SESSION_BOX_PREFIX = 'chat_session_';
  static const String CHAT_HISTORY_BOX_PREFIX = 'chat_history_';
  static const String _K_SESSION_ID_KEY = 'session_id';
  static const String _K_SESSIONS_INDEX_KEY = 'sessions_index';

  final UserDataProvider _userDataProvider;

  ChatPersistenceService(this._userDataProvider);

  String get _userKey => _userDataProvider.authenticationModel.accessToken?.hashCode.toString() ?? 'unknown';

  String get _historyBoxName => '$CHAT_HISTORY_BOX_PREFIX$_userKey';

  String get _sessionBoxName => '$CHAT_SESSION_BOX_PREFIX$_userKey';

  Future<Box<ChatMessagePersistent>> _openHistoryBox() => Hive.openBox<ChatMessagePersistent>(_historyBoxName);

  Future<Box<String>> _openSessionBox() => Hive.openBox<String>(_sessionBoxName);

  bool get _isLoggedIn => _userDataProvider.isLoggedIn;

  Future<List<ChatSessionMeta>> loadSessionsIndex() async {
    if (!_isLoggedIn) return [];
    final sessionBox = await _openSessionBox();
    final raw = sessionBox.get(_K_SESSIONS_INDEX_KEY);
    final hasRaw = raw != null && raw.isNotEmpty;
    if (!hasRaw) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final sessions = list.map(ChatSessionMeta.fromJson).toList();
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessionsIndex(List<ChatSessionMeta> items) async {
    if (!_isLoggedIn) return;
    final sessionBox = await _openSessionBox();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sessionBox.put(_K_SESSIONS_INDEX_KEY, raw);
  }

  Future<void> saveMessagesForSession(String sessionId, List<types.Message> messages) async {
    if (!_isLoggedIn) return;
    final box = await _openHistoryBox();
    final map = box.toMap().cast<dynamic, ChatMessagePersistent>();
    for (final entry in map.entries) {
      if (entry.value.sessionId == sessionId) await box.delete(entry.key);
    }

    for (final message in messages) {
      if (message is types.TextMessage) {
        final persistentMessage = ChatMessagePersistent(
          id: message.id,
          text: message.text,
          authorId: message.author.id,
          createdAt: message.createdAt ?? DateTime.now().millisecondsSinceEpoch,
          isFromUser: message.author.id == 'user-id',
          sessionId: sessionId,
        );
        await box.add(persistentMessage);
      }
    }
  }

  Future<List<types.Message>> loadMessagesForSession(String sessionId) async {
    if (!_isLoggedIn) return [];
    final box = await _openHistoryBox();
    final results = <types.Message>[];
    for (final persistent in box.values) {
      if (persistent.sessionId == sessionId) {
        results.add(
          types.TextMessage(
            id: persistent.id,
            text: persistent.text,
            author: types.User(id: persistent.authorId),
            createdAt: persistent.createdAt,
          ),
        );
      }
    }
    results.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return results;
  }

  Future<void> deleteSession(String sessionId) async {
    if (!_isLoggedIn) return;
    final box = await _openHistoryBox();
    final map = box.toMap().cast<dynamic, ChatMessagePersistent>();
    for (final entry in map.entries) {
      if (entry.value.sessionId == sessionId) await box.delete(entry.key);
    }

    final index = await loadSessionsIndex();
    final updated = index.where((s) => s.id != sessionId).toList();
    await saveSessionsIndex(updated);
    final sessionBox = await _openSessionBox();
    final last = sessionBox.get(_K_SESSION_ID_KEY);
    if (last == sessionId) await sessionBox.delete(_K_SESSION_ID_KEY);
  }

  Future<void> saveLoggedInUserMessages(List<types.Message> messages, String sessionId) async {
    if (!_isLoggedIn) return;
    await saveMessagesForSession(sessionId, messages);
    await saveSessionId(sessionId);
  }

  Future<List<types.Message>> loadLoggedInUserMessages() async {
    if (!_isLoggedIn) return [];
    final sessionId = await loadSessionId();
    final hasSessionId = sessionId != null && sessionId.isNotEmpty;
    if (!hasSessionId) return [];
    return loadMessagesForSession(sessionId);
  }

  Future<void> saveSessionId(String sessionId) async {
    if (!_isLoggedIn) return;
    final sessionBox = await _openSessionBox();
    await sessionBox.put(_K_SESSION_ID_KEY, sessionId);
  }

  Future<String?> loadSessionId() async {
    if (!_isLoggedIn) return null;
    try {
      final sessionBox = await _openSessionBox();
      return sessionBox.get(_K_SESSION_ID_KEY);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserChatData() async {
    if (!_isLoggedIn) return;

    try {
      final messageBox = await _openHistoryBox();
      await messageBox.deleteFromDisk();

      final sessionBox = await _openSessionBox();
      await sessionBox.deleteFromDisk();
    } catch (_) {}
  }
}
