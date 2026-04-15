import 'dart:collection';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_persistence.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_session_creation.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_stream.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._userDataProvider);

  static const String _defaultSessionTitle = 'New Chat';
  static const String _assistantAuthorId = 'assistant';

  final UserDataProvider _userDataProvider;
  final List<AssistantChatMessage> _messages = <AssistantChatMessage>[];
  final List<ChatSessionMeta> _persistedSessions = <ChatSessionMeta>[];
  final List<ChatSessionMeta> _guestSessions = <ChatSessionMeta>[];
  final Map<String, List<AssistantChatMessage>> _sessionMessagesById = <String, List<AssistantChatMessage>>{};
  final Map<String, int?> _parentMessageIdsBySession = <String, int?>{};
  final Set<String> _streamingSessionIds = <String>{};

  late final ChatPersistenceService _chatPersistenceService = ChatPersistenceService(_userDataProvider);
  late final ChatSessionService _chatSessionService = ChatSessionService(_userDataProvider);

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool? _lastKnownLoginState;
  String? _activeSessionId;
  String? _errorMessage;

  List<AssistantChatMessage> get messages => List<AssistantChatMessage>.unmodifiable(_messages);

  List<ChatSessionMeta> get sessions => List<ChatSessionMeta>.unmodifiable(
        _userDataProvider.isLoggedIn ? _persistedSessions : _guestSessions,
      );

  bool get hasMessages => _messages.isNotEmpty;
  bool get isInitializing => _isInitializing;
  bool get isStreaming => _activeSessionId != null && _streamingSessionIds.contains(_activeSessionId);
  String? get activeSessionId => _activeSessionId;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_isInitializing) return;

    final bool isLoggedIn = _userDataProvider.isLoggedIn;
    if (_isInitialized && _lastKnownLoginState == isLoggedIn) return;

    _isInitializing = true;
    _lastKnownLoginState = isLoggedIn;
    notifyListeners();

    try {
      if (isLoggedIn) {
        _persistedSessions
          ..clear()
          ..addAll(_dedupeSessions(await _chatPersistenceService.loadSessionsIndex()));

        final String? savedSessionId = await _chatPersistenceService.loadSessionId();
        final String? sessionToOpen = _resolveSessionToOpen(savedSessionId);
        if (sessionToOpen != null) {
          await _loadPersistedSession(
            sessionToOpen,
            saveAsActive: savedSessionId != sessionToOpen,
          );
        } else {
          _messages.clear();
          _activeSessionId = null;
        }
      } else if (_sessionMessagesById.isEmpty) {
        _messages.clear();
        _activeSessionId = null;
      }
    } finally {
      _isInitialized = true;
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> syncLoginState(bool isLoggedIn) async {
    if (_lastKnownLoginState == null) {
      _lastKnownLoginState = isLoggedIn;
      return;
    }
    if (_lastKnownLoginState == isLoggedIn) return;

    _isInitialized = false;
    _errorMessage = null;
    _streamingSessionIds.clear();
    _sessionMessagesById.clear();
    _parentMessageIdsBySession.clear();

    if (!isLoggedIn) {
      _messages.clear();
      _activeSessionId = null;
      _persistedSessions.clear();
      _guestSessions.clear();
    }

    await initialize();
  }

  Future<void> startNewChat() async {
    final String? previousSessionId = _activeSessionId;
    if (previousSessionId != null && previousSessionId.isNotEmpty) {
      _setSessionMessages(previousSessionId, _messages);
      await _persistSessionState(
        previousSessionId,
        saveAsActive: false,
      );
    }

    _messages.clear();
    _activeSessionId = null;
    _errorMessage = null;

    if (_userDataProvider.isLoggedIn) {
      await _chatPersistenceService.clearSessionId();
    }

    notifyListeners();
  }

  Future<void> openSession(String sessionId) async {
    _errorMessage = null;

    if (_sessionMessagesById.containsKey(sessionId)) {
      _activeSessionId = sessionId;
      _messages
        ..clear()
        ..addAll(_sessionMessagesById[sessionId] ?? const <AssistantChatMessage>[]);
      _parentMessageIdsBySession[sessionId] ??= _deriveParentMessageId(_messages);
      if (_userDataProvider.isLoggedIn) {
        await _chatPersistenceService.saveSessionId(sessionId);
      }
      notifyListeners();
      return;
    }

    if (_userDataProvider.isLoggedIn) {
      await _loadPersistedSession(sessionId, saveAsActive: true);
    } else {
      final List<AssistantChatMessage> guestMessages =
          _sessionMessagesById[sessionId] ?? const <AssistantChatMessage>[];
      _messages
        ..clear()
        ..addAll(guestMessages);
      _activeSessionId = sessionId;
      _parentMessageIdsBySession[sessionId] = _deriveParentMessageId(_messages);
      notifyListeners();
    }
  }

  Future<void> sendMessage(String rawMessage) async {
    final String message = rawMessage.trim();
    if (message.isEmpty || isStreaming) return;

    _errorMessage = null;
    final String? sessionId = await _ensureActiveSession();
    if (sessionId == null) {
      notifyListeners();
      return;
    }

    final List<AssistantChatMessage> sessionMessages =
        List<AssistantChatMessage>.from(_sessionMessagesById[sessionId] ?? _messages);

    final DateTime now = DateTime.now();
    final AssistantChatMessage userMessage = AssistantChatMessage(
      id: 'user-${now.microsecondsSinceEpoch}',
      text: message,
      createdAt: now,
      isFromUser: true,
    );
    final AssistantChatMessage placeholderMessage = AssistantChatMessage(
      id: 'assistant-pending-${now.microsecondsSinceEpoch}',
      text: '',
      createdAt: now,
      isFromUser: false,
      isStreaming: true,
    );

    sessionMessages
      ..add(userMessage)
      ..add(placeholderMessage);
    _setSessionMessages(sessionId, sessionMessages);
    _streamingSessionIds.add(sessionId);
    _upsertSessionMeta(
      sessionId,
      title: _sessionTitleForMessage(message),
      updatedAt: now,
    );
    await _persistSessionState(
      sessionId,
      saveAsActive: _activeSessionId == sessionId,
    );
    notifyListeners();

    int? reservedAssistantMessageId;
    final ChatMessageStreamService chatMessageStreamService = ChatMessageStreamService(_userDataProvider);

    try {
      await for (final chunk in chatMessageStreamService.streamMessage(
        message: message,
        chatSessionId: sessionId,
        parentMessageId: _parentMessageIdsBySession[sessionId],
      )) {
        if (chunk.messageId != null) {
          reservedAssistantMessageId = chunk.messageId;
        }

        final int placeholderIndex =
            sessionMessages.indexWhere((AssistantChatMessage item) => item.id == placeholderMessage.id);
        if (placeholderIndex == -1) continue;

        final AssistantChatMessage currentMessage = sessionMessages[placeholderIndex];
        final List<ChatCitationReference> citations = chunk.citations ?? currentMessage.citations;

        final String nextText = chunk.delta.isEmpty ? currentMessage.text : '${currentMessage.text}${chunk.delta}';
        sessionMessages[placeholderIndex] = currentMessage.copyWith(
          id: chunk.done ? (reservedAssistantMessageId?.toString() ?? currentMessage.id) : currentMessage.id,
          text: nextText,
          isStreaming: !chunk.done,
          citations: citations,
        );
        _setSessionMessages(sessionId, sessionMessages);
        notifyListeners();
      }
    } catch (_) {
      _errorMessage = ErrorConstants.TRITONGPT_UNAVAILABLE;
      final int placeholderIndex =
          sessionMessages.indexWhere((AssistantChatMessage item) => item.id == placeholderMessage.id);
      if (placeholderIndex != -1) {
        sessionMessages[placeholderIndex] = sessionMessages[placeholderIndex].copyWith(
          text: ErrorConstants.TRITONGPT_UNAVAILABLE,
          isStreaming: false,
        );
      }
      _setSessionMessages(sessionId, sessionMessages);
    } finally {
      _parentMessageIdsBySession[sessionId] = reservedAssistantMessageId ?? _deriveParentMessageId(sessionMessages);
      _streamingSessionIds.remove(sessionId);
      _setSessionMessages(sessionId, sessionMessages);
      await _persistSessionState(
        sessionId,
        saveAsActive: _activeSessionId == sessionId,
      );
      notifyListeners();
    }
  }

  Future<String?> _ensureActiveSession() async {
    if (_activeSessionId != null && _activeSessionId!.isNotEmpty) {
      return _activeSessionId;
    }

    final session = await _chatSessionService.createChatSession();
    if (session == null) {
      _errorMessage = _chatSessionService.error ?? 'Unable to start a new chat.';
      return null;
    }

    _activeSessionId = session.chatSessionId;
    _parentMessageIdsBySession[_activeSessionId!] = null;
    _sessionMessagesById.putIfAbsent(_activeSessionId!, () => <AssistantChatMessage>[]);

    if (_userDataProvider.isLoggedIn) {
      await _chatPersistenceService.saveSessionId(_activeSessionId!);
    }

    return _activeSessionId;
  }

  Future<void> _loadPersistedSession(
    String sessionId, {
    required bool saveAsActive,
  }) async {
    final List<AssistantChatMessage> persistedMessages = (await _chatPersistenceService
            .loadMessagesForSession(sessionId))
        .map(AssistantChatMessage.fromPersistent)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _setSessionMessages(sessionId, persistedMessages, updateActiveSession: false);
    _messages
      ..clear()
      ..addAll(persistedMessages);
    _activeSessionId = sessionId;
    _parentMessageIdsBySession[sessionId] = _deriveParentMessageId(persistedMessages);

    if (saveAsActive) {
      await _chatPersistenceService.saveSessionId(sessionId);
    }

    notifyListeners();
  }

  Future<void> _persistSessionState(
    String sessionId, {
    required bool saveAsActive,
  }) async {
    final List<AssistantChatMessage> sessionMessages =
        _sessionMessagesById[sessionId] ?? const <AssistantChatMessage>[];
    if (sessionId.isEmpty) return;

    if (_userDataProvider.isLoggedIn) {
      await _chatPersistenceService.saveMessagesForSession(
        sessionId,
        sessionMessages
            .map(
              (message) => message.toPersistent(
                sessionId: sessionId,
                authorId: message.isFromUser ? _userAuthorId : _assistantAuthorId,
                parentMessageId: message.isFromUser ? _parentMessageIdsBySession[sessionId]?.toString() : null,
              ),
            )
            .toList(),
      );
      await _chatPersistenceService.saveSessionsIndex(_persistedSessions);
      if (saveAsActive) {
        await _chatPersistenceService.saveSessionId(sessionId);
      }
      return;
    }

    _setSessionMessages(sessionId, sessionMessages, updateActiveSession: false);
  }

  void _upsertSessionMeta(
    String sessionId, {
    required String title,
    required DateTime updatedAt,
  }) {
    final List<ChatSessionMeta> target = _userDataProvider.isLoggedIn ? _persistedSessions : _guestSessions;
    final int existingIndex = target.indexWhere((session) => session.id == sessionId);
    final DateTime createdAt = existingIndex == -1 ? updatedAt : target[existingIndex].createdAt;
    final ChatSessionMeta updatedSession = ChatSessionMeta(
      id: sessionId,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    if (existingIndex != -1) {
      target.removeAt(existingIndex);
    }

    target.insert(0, updatedSession);
    final List<ChatSessionMeta> dedupedSessions = _dedupeSessions(target);
    target
      ..clear()
      ..addAll(dedupedSessions);
  }

  int? _deriveParentMessageId(List<AssistantChatMessage> messages) {
    for (final AssistantChatMessage message in messages.reversed) {
      if (message.isFromUser) continue;
      final int? parsedId = int.tryParse(message.id);
      if (parsedId != null) return parsedId;
    }
    return null;
  }

  String get _userAuthorId {
    final profile = _userDataProvider.userProfileModel;
    return profile.pid ?? profile.username ?? 'user';
  }

  String _sessionTitleForMessage(String text) {
    final String normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return _defaultSessionTitle;
    if (normalized.length <= 36) return normalized;
    return '${normalized.substring(0, 36).trimRight()}...';
  }

  String? _resolveSessionToOpen(String? savedSessionId) {
    if (savedSessionId != null && savedSessionId.isNotEmpty) {
      final bool hasSavedSession = _persistedSessions.any(
        (ChatSessionMeta session) => session.id == savedSessionId,
      );
      if (hasSavedSession) return savedSessionId;
    }

    if (_persistedSessions.isEmpty) return null;
    return _persistedSessions.first.id;
  }

  List<ChatSessionMeta> _dedupeSessions(List<ChatSessionMeta> sessions) {
    final LinkedHashMap<String, ChatSessionMeta> uniqueSessions = LinkedHashMap<String, ChatSessionMeta>();
    final List<ChatSessionMeta> sortedSessions = List<ChatSessionMeta>.from(sessions)
      ..sort((ChatSessionMeta a, ChatSessionMeta b) => b.updatedAt.compareTo(a.updatedAt));

    for (final ChatSessionMeta session in sortedSessions) {
      uniqueSessions.putIfAbsent(session.id, () => session);
    }

    return uniqueSessions.values.toList();
  }

  void _setSessionMessages(
    String sessionId,
    List<AssistantChatMessage> messages, {
    bool updateActiveSession = true,
  }) {
    final List<AssistantChatMessage> copiedMessages = List<AssistantChatMessage>.from(messages);
    _sessionMessagesById[sessionId] = copiedMessages;

    if (updateActiveSession && _activeSessionId == sessionId) {
      _messages
        ..clear()
        ..addAll(copiedMessages);
    }
  }
}
