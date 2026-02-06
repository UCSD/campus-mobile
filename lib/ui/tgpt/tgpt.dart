import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_session_creation.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_stream.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_feedback.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'slider.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';
import 'package:campus_mobile_experimental/core/services/tgpt_services/chat_persistence.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './dev_tools/blue_button.dart'; // Blue-button diagnostics (disable by commenting out)
import './dev_tools/red_button.dart'; // Red-button diagnostics (disable by commenting out)

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ---------- Composer ----------
  void _sendFromComposer() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    setState(() {}); // refresh send button disabled state
    _handleSendPressed(types.PartialText(text: text));
  }

  final ChatFeedbackService _chatFeedbackService = ChatFeedbackService();
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user-id');
  late ChatSessionService _chatSessionService;
  late UserDataProvider _userDataProvider;
  late bool _isLoadingSession = true;

  // ---------- Sessions State ----------
  List<ChatSessionMeta> _sessions = [];
  String? _currentSessionId;
  final Map<String, List<types.Message>> _guestSessions = {};

  // ---------- Persistence ----------
  ChatPersistenceService? _persistenceService;

  // ---------- Sidebar ----------
  bool _isSidebarOpen = false;
  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  void _closeSidebar() {
    setState(() => _isSidebarOpen = false);
  }

  final _textController = TextEditingController();
  final _composerFocus = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  // ---------- Utils ----------
  String _titleFrom(String text) {
    final t = text.trim().replaceAll('\n', ' ');
    return (t.length <= 60) ? t : '${t.substring(0, 60)}…';
  }

  // ---------- Sessions Index ----------
  Future<void> _loadSessionsIndex() async {
    final canPersist = _userDataProvider.isLoggedIn && _persistenceService != null;
    if (!canPersist) return;
    _sessions = await _persistenceService!.loadSessionsIndex();
    setState(() {});
  }

  Future<void> _persistSessionsIndex() async {
    final canPersist = _userDataProvider.isLoggedIn && _persistenceService != null;
    if (!canPersist) return;
    await _persistenceService!.saveSessionsIndex(_sessions);
  }

  // ---------- Documents Index ----------
  Future<void> _loadDocumentsIndex() async {
    final canPersist = _userDataProvider.isLoggedIn && _persistenceService != null;
    if (!canPersist) return;
    // _documents = await _persistenceService!.loadDocumentsIndex();
    setState(() {});
  }

  Future<void> _persistDocumentsIndex() async {
    final canPersist = _userDataProvider.isLoggedIn && _persistenceService != null;
    if (!canPersist) return;
    // _documents = await _persistenceService!.loadDocumentsIndex();
  }

  // ---------- Related Questions ----------
  List<String> _extractRelatedQuestions(String text) {
    final rx = RegExp(r'^\s*(?:[-*]\s*)?\[rq\]\s*(.+?)\s*$', multiLine: true);
    final seen = <String>{};
    final out = <String>[];
    for (final m in rx.allMatches(text)) {
      final q = m.group(1)!.trim();
      final isNewQuestion = q.isNotEmpty && !seen.contains(q);
      if (isNewQuestion) {
        seen.add(q);
        out.add(q);
      }
    }
    return out;
  }

  String _stripRelatedQuestionsAndHeading(String text, {required bool hasRQs}) {
    if (!hasRQs) return text;
    final lines = text.split(RegExp(r'\r?\n'));
    final hrLine = RegExp(r'^\s*(?:-{3,}|_{3,}|\*{3,})\s*$');
    final rqLine = RegExp(r'^\s*(?:[-*]\s*)?\[rq\]\s*.+$', multiLine: false);
    final relatedHeading = RegExp(
      r'^\s{0,3}(?:#{1,6}\s*|[*_]{0,3})\s*related\s+questions?\s*[:：]?\s*[*_]{0,3}\s*$',
      caseSensitive: false,
    );

    final kept = <String>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i];

      if (relatedHeading.hasMatch(line)) {
        final hasTrailingBlank = kept.isNotEmpty && kept.last.trim().isEmpty;
        final lastIsHr = kept.isNotEmpty && hrLine.hasMatch(kept.last);
        if (hasTrailingBlank) {
          final hasHrBeforeBlank = kept.length >= 2 && hrLine.hasMatch(kept[kept.length - 2]);
          if (hasHrBeforeBlank) {
            kept.removeLast();
            kept.removeLast();
          } else {
            kept.removeLast();
          }
        } else if (lastIsHr) {
          kept.removeLast();
        }

        i++;

        final hasLeadingBlank = i < lines.length && lines[i].trim().isEmpty;
        if (hasLeadingBlank) i++;
        while (i < lines.length && rqLine.hasMatch(lines[i])) {
          i++;
        }
        final hasTrailingBlankLine = i < lines.length && lines[i].trim().isEmpty;
        if (hasTrailingBlankLine) i++;
        continue;
      }

      if (rqLine.hasMatch(line)) {
        i++;
        continue;
      }

      kept.add(line);
      i++;
    }

    final cleaned = kept.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trimRight();
    return cleaned;
  }

  // ---------- Composer Helpers ----------
  void _onTapRelatedQuestion(String q) {
    setState(() {
      _textController.text = q;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    });
    _composerFocus.requestFocus();
  }

  // ---------- Session Lifecycle ----------
  Future<void> _createNewSessionAndSwitch() async {
    await _persistCurrentSessionMessages();

    final session = await _chatSessionService.createChatSession();
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'UC San Diego Assistant is currently unavailable. Please try again later or check your connection.')),
      );
      return;
    }

    final now = DateTime.now();
    final meta = ChatSessionMeta(
      id: session.chatSessionId,
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
    );

    if (_userDataProvider.isLoggedIn) {
      _sessions.insert(0, meta);
      await _persistSessionsIndex();
      await _persistenceService!.saveMessagesForSession(meta.id, []);
      await _persistenceService!.saveSessionId(meta.id);
    } else {
      _guestSessions[meta.id] = [];
      _sessions.insert(0, meta);
    }

    setState(() {
      _currentSessionId = meta.id;
      _messages.clear();
    });
  }

  // ---------- Message Persistence ----------
  Future<void> _persistCurrentSessionMessages() async {
    final id = _currentSessionId;
    if (id == null) return;

    if (_userDataProvider.isLoggedIn) {
      await _persistenceService?.saveMessagesForSession(id, _messages);
    } else {
      _guestSessions[id] = List<types.Message>.from(_messages);
    }
  }

  // ---------- Session Navigation ----------
  Future<void> _switchToSession(String sessionId) async {
    await _persistCurrentSessionMessages();

    List<types.Message> msgs = [];
    if (_userDataProvider.isLoggedIn) {
      msgs = await _persistenceService!.loadMessagesForSession(sessionId);
      await _persistenceService!.saveSessionId(sessionId);
    } else {
      msgs = _guestSessions[sessionId] ?? [];
    }

    setState(() {
      _currentSessionId = sessionId;
      _messages
        ..clear()
        ..addAll(msgs);
    });
  }

  // ---------- Session Title ----------
  Future<void> _maybeSetTitleFromFirstUser(types.TextMessage userMsg) async {
    final id = _currentSessionId;
    if (id == null) return;
    final idx = _sessions.indexWhere((s) => s.id == id);
    if (idx < 0) return;

    final userCount = _messages.whereType<types.TextMessage>().where((m) => m.author.id == _user.id).length;

    if (userCount == 1) {
      final newTitle = _titleFrom(userMsg.text);
      final now = DateTime.now();
      _sessions[idx] = _sessions[idx].copyWith(title: newTitle, updatedAt: now);

      final meta = _sessions.removeAt(idx);
      _sessions.insert(0, meta);

      if (_userDataProvider.isLoggedIn) await _persistSessionsIndex();
      setState(() {});
    }
  }

  // ---------- Session Ordering ----------
  Future<void> _touchSessionUpdated() async {
    final id = _currentSessionId;
    if (id == null) return;
    final idx = _sessions.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    _sessions[idx] = _sessions[idx].copyWith(updatedAt: DateTime.now());
    final meta = _sessions.removeAt(idx);
    _sessions.insert(0, meta);
    if (_userDataProvider.isLoggedIn) await _persistSessionsIndex();
  }

  // ---------- Initialization ----------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    _chatSessionService = ChatSessionService(_userDataProvider);

    if (_userDataProvider.isLoggedIn) {
      _persistenceService = ChatPersistenceService(_userDataProvider);
    } else {
      _persistenceService = null;
    }

    _initializeChatSession();
  }

  Future<void> _initializeChatSession() async {
    setState(() => _isLoadingSession = true);
    try {
      if (_userDataProvider.isLoggedIn) {
        await _loadSessionsIndex();
        await _loadDocumentsIndex();

        if (_sessions.isEmpty) {
          await _createNewSessionAndSwitch();
        } else {
          await _switchToSession(_sessions.first.id);
        }
      } else {
        _sessions.clear();
        _guestSessions.clear();
        await _createNewSessionAndSwitch();
      }
    } catch (e, st) {
      debugPrint('initializeChatSession error: $e\n$st');
      _sessions.clear();
      _guestSessions.clear();
      await _createNewSessionAndSwitch();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Started a temporary session.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingSession = false);
    }
  }

  // ---------- Composer UI ----------
  Widget _buildComposer(BuildContext context) {
    final canSend = _textController.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF747678)),
            boxShadow: const [
              BoxShadow(blurRadius: 12, offset: Offset(0, 2), color: Color(0x11000000)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text input
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  child: TextField(
                    controller: _textController,
                    focusNode: _composerFocus,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF182B49), fontWeight: FontWeight.w400),
                    decoration: const InputDecoration(
                      hintText: 'Talk with UC San Diego Assistant...',
                      hintStyle: TextStyle(fontSize: 14, color: Color(0xFF757575), fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (canSend) _sendFromComposer();
                    },
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: canSend ? _sendFromComposer : null,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: SvgPicture.asset(
                        'assets/images/tgpt/send-message.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    if (_isLoadingSession) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF182B49),
        foregroundColor: Colors.white,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/images/tgpt/tritongpt-header.svg',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // ...other action buttons...
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: _userDataProvider.isLoggedIn
                          ? SvgPicture.asset(
                              'assets/images/tgpt/pin-sidebar.svg',
                              width: 22,
                              height: 22,
                              color: Color(0xFF747678),
                            )
                          : const Icon(
                              Icons.login_rounded,
                              color: Color(0xFF00629B),
                              size: 26,
                            ),
                      onPressed: _toggleSidebar,
                    ),
                    const Spacer(),
                    LimitTestButton(), // Blue-button diagnostics (disable by commenting out)
                    RedDebugButton(), // Red-button diagnostics (disable by commenting out)
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/tgpt/new_chat2.svg',
                        width: 24,
                        height: 24,
                        color: Color(0xFF00629B),
                      ),
                      tooltip: 'New Chat',
                      onPressed: _createNewSessionAndSwitch,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Chat(
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  user: _user,
                  customBottomWidget: _buildComposer(context),
                  textMessageBuilder: (types.TextMessage message, {required int messageWidth, required bool showName}) {
                    final isUser = message.author.id == _user.id;
                    final List<String> rqs =
                        (!isUser) ? (message.metadata?['rqs'] as List?)?.cast<String>() ?? const [] : const [];
                    final String displayText =
                        (!isUser) ? (message.metadata?['display_text'] as String?) ?? message.text : message.text;
                    final content = MarkdownBody(
                      data: displayText,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontFamily: 'Brix Sans',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: isUser ? Color(0xFF182B49) : Color(0xFF182B49),
                          height: 1.35,
                        ),
                        strong: TextStyle(
                          fontFamily: 'Brix Sans',
                          fontWeight: FontWeight.w600,
                          color: isUser ? Color(0xFF182B49) : Color(0xFF182B49),
                          fontSize: 15.0,
                        ),
                      ),
                      builders: {'citation': CitationMarkdownBuilder(isUser: isUser)},
                      extensionSet: md.ExtensionSet(
                        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                        [CitationInlineSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                      ),
                    );
                    if (!isUser) {
                      final isFinalized = message.metadata != null && message.metadata!['message_id'] != null;
                      int chatMessageId = 0;
                      if (isFinalized) {
                        chatMessageId = message.metadata!['message_id'] is int
                            ? message.metadata!['message_id'] as int
                            : int.tryParse(message.metadata!['message_id'].toString()) ?? 0;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/tgpt/tgpt-icon.png', width: 22, height: 22, fit: BoxFit.contain),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  content,
                                  if (rqs.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(height: 1, color: const Color(0xFFE6E6E6)),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Related Questions',
                                              style: TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF182B49))),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: rqs
                                                .map((q) => ActionChip(
                                                      label: Text(q, style: const TextStyle(fontSize: 13)),
                                                      onPressed: () => _onTapRelatedQuestion(q),
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      elevation: 0,
                                                      backgroundColor: Color(0xFFF3F4F6),
                                                    ))
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (isFinalized)
                                    FeedbackRow(
                                      initialUp: message.metadata?['thumbs_up'] == true,
                                      initialDown: message.metadata?['thumbs_down'] == true,
                                      onSend: (isPositive) async {
                                        final ok = await _chatFeedbackService.sendFeedback(
                                          chatMessageId: chatMessageId,
                                          isPositive: isPositive,
                                        );
                                        final canUpdate = ok && mounted;
                                        if (canUpdate) {
                                          final idx = _messages.indexWhere((m) => m.id == message.id);
                                          final isTextMessage = idx >= 0 && _messages[idx] is types.TextMessage;
                                          if (isTextMessage) {
                                            final oldMsg = _messages[idx] as types.TextMessage;
                                            final newMeta = Map<String, dynamic>.from(oldMsg.metadata ?? {});
                                            newMeta['thumbs_up'] = isPositive;
                                            newMeta['thumbs_down'] = !isPositive;
                                            _persistenceService?.saveMessagesForSession(_currentSessionId!, [
                                              for (var i = 0; i < _messages.length; i++)
                                                if (i == idx) oldMsg.copyWith(metadata: newMeta) else _messages[i],
                                            ]);
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('Thanks for your feedback! 👍'),
                                                duration: Duration(seconds: 2)),
                                          );
                                        }
                                        return ok;
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: content,
                    );
                  },
                  theme: DefaultChatTheme(
                    backgroundColor: const Color(0xFFFFFFFF),
                    messageBorderRadius: 16,
                    messageInsetsHorizontal: 32,
                    messageInsetsVertical: 48,
                    primaryColor: const Color(0xFFF3F4F6),
                    secondaryColor: Colors.white,
                    sentMessageBodyTextStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    receivedMessageBodyTextStyle: const TextStyle(color: Colors.black87, fontSize: 15),
                  ),
                  emptyState: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/tgpt/uc-san-diego-assistant.svg',
                          height: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text('This assistant has access to campus information.',
                            style: TextStyle(
                                color: Color(0xFF757575),
                                fontFamily: 'Brix Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isSidebarOpen)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(color: const Color(0xFF000000).withOpacity(0.04)),
                  SideSlider(
                    isOpen: _isSidebarOpen,
                    onClose: _closeSidebar,
                    width: 300,
                    onNewChat: _createNewSessionAndSwitch,
                    onSelectSession: _switchToSession,
                    sessions: _sessions,
                    isLoggedIn: _userDataProvider.isLoggedIn,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

// ---------- Stream Updates ----------
  void _updateMessageText(String id, String newText) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final existing = _messages[idx];
    if (existing is types.TextMessage) {
      final updated = existing.copyWith(text: newText);
      setState(() {
        _messages.removeAt(idx);
        _messages.insert(idx, updated);
      });
    }
  }

  void _updateMessageMetadata(String id, Map<String, dynamic> newMeta) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final existing = _messages[idx];
    if (existing is types.TextMessage) {
      final merged = Map<String, dynamic>.from(existing.metadata ?? {});
      merged.addAll(newMeta);
      final updated = existing.copyWith(metadata: merged);
      setState(() {
        _messages.removeAt(idx);
        _messages.insert(idx, updated);
      });
    }
  }

  void _finalizeStreamMessage(String id, String fullText, {int? messageId}) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final existing = _messages[idx];
    if (existing is! types.TextMessage) return;

    final newMeta = Map<String, dynamic>.from(existing.metadata ?? {});
    if (messageId != null) newMeta['message_id'] = messageId;

    final rqs = _extractRelatedQuestions(fullText);
    final displayText = _stripRelatedQuestionsAndHeading(
      fullText,
      hasRQs: rqs.isNotEmpty,
    );
    newMeta['rqs'] = rqs;
    newMeta['display_text'] = displayText;

    final updated = existing.copyWith(text: fullText, metadata: newMeta);
    setState(() {
      _messages.removeAt(idx);
      _messages.insert(idx, updated);
    });
  }

// ---------- Send Flow ----------
  void _handleSendPressed(types.PartialText message) async {
    final missingSessionId = _currentSessionId == null || _currentSessionId!.isEmpty;
    if (missingSessionId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'UC San Diego Assistant is currently unavailable. Please try again later or check your connection.')),
      );
      return;
    }

    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: UniqueKey().toString(),
      text: message.text,
    );
    _addMessage(userMessage);
    await _maybeSetTitleFromFirstUser(userMessage);
    await _touchSessionUpdated();

    String currentText = '';
    final streamSvc = ChatMessageStreamService(_userDataProvider);
    final String streamMsgId = 'stream-${DateTime.now().microsecondsSinceEpoch}';
    final assistantAuthor = const types.User(id: 'assistant-id');

    final placeholder = types.TextMessage(
      author: assistantAuthor,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: streamMsgId,
      text: '_Thinking …_',
    );

    setState(() => _messages.insert(0, placeholder));
    var lastPaint = DateTime.now();
    var finalized = false;
    int? streamMessageId;

    try {
      await for (final chunk in streamSvc.streamMessage(
        message: message.text,
        chatSessionId: _currentSessionId!,
      )) {
        if (chunk.done) break;

        if (chunk.messageId != null) {
          streamMessageId = chunk.messageId;
          _updateMessageMetadata(streamMsgId, {'message_id': streamMessageId});
        }

        final hasDelta = chunk.delta.isNotEmpty;
        final shouldAppend = !finalized && hasDelta;
        if (shouldAppend) currentText += chunk.delta;

        final hasFullMessage = chunk.fullMessage != null && chunk.fullMessage!.isNotEmpty;
        if (hasFullMessage) {
          currentText = chunk.fullMessage!;
          finalized = true;
          _finalizeStreamMessage(
            streamMsgId,
            currentText,
            messageId: streamMessageId ?? chunk.messageId,
          );
        } else {
          final now = DateTime.now();
          if (now.difference(lastPaint).inMilliseconds >= 33) {
            _updateMessageText(streamMsgId, currentText);
            lastPaint = now;
            await Future.delayed(Duration.zero);
          }
        }
      }

      if (!finalized) {
        _finalizeStreamMessage(
          streamMsgId,
          currentText,
          messageId: streamMessageId,
        );
      }
    } catch (e) {
      _updateMessageText(streamMsgId, '⚠️ Streaming error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Streaming error: $e')),
      );
    } finally {
      await _persistCurrentSessionMessages();
    }
  }

  // ---------- Message Insert ----------
  void _addMessage(types.Message m) async {
    setState(() => _messages.insert(0, m));
    await _persistCurrentSessionMessages();
  }
}

// ---------- Feedback ----------
class FeedbackRow extends StatefulWidget {
  final bool initialUp;
  final bool initialDown;
  final Future<bool> Function(bool isPositive) onSend;

  const FeedbackRow({
    super.key,
    required this.initialUp,
    required this.initialDown,
    required this.onSend,
  });

  @override
  State<FeedbackRow> createState() => _FeedbackRowState();
}

class _FeedbackRowState extends State<FeedbackRow> {
  late bool up = widget.initialUp;
  late bool down = widget.initialDown;
  bool sending = false;

  void _send(bool isPositive) {
    if (sending) return;
    setState(() {
      sending = true;
      if (isPositive) {
        up = true;
        down = false;
      } else {
        down = true;
        up = false;
      }
    });

    widget.onSend(isPositive).then((ok) {
      if (!mounted) return;
      if (!ok) {
        setState(() {
          // revert
          up = widget.initialUp;
          down = widget.initialDown;
        });
      }
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        up = widget.initialUp;
        down = widget.initialDown;
      });
    }).whenComplete(() {
      if (!mounted) return;
      setState(() => sending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(up ? Icons.thumb_up : Icons.thumb_up_outlined, color: up ? Colors.green : Colors.black),
          onPressed: sending || up ? null : () => _send(true),
          tooltip: 'Thumbs Up',
        ),
        IconButton(
          icon: Icon(down ? Icons.thumb_down : Icons.thumb_down_outlined, color: down ? Colors.red : Colors.black),
          onPressed: sending || down ? null : () => _send(false),
          tooltip: 'Thumbs Down',
        ),
      ],
    );
  }
}

// ---------- Citations ----------
class CitationInlineSyntax extends md.InlineSyntax {
  CitationInlineSyntax() : super(r'(\[\[?)(\d+)(\]?\])\(([^)]+)\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final num = match.group(2)!;
    final url = match.group(4)!;
    parser.addNode(md.Element.text('citation', '$num|$url'));
    return true;
  }
}

class CitationMarkdownBuilder extends MarkdownElementBuilder {
  final bool isUser;
  CitationMarkdownBuilder({required this.isUser});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'citation') {
      final parts = element.textContent.split('|');
      final num = parts[0];
      final url = parts.length > 1 ? parts[1] : null;

      final bubble = GestureDetector(
        onTap: url != null ? () => launchUrl(Uri.parse(url)) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE6EFF5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00629B), width: 1.5),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontFamily: 'Brix Sans',
              color: Color(0xFF00629B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            child: Text(num),
          ),
        ),
      );

      return RichText(
        text: TextSpan(
          style: preferredStyle,
          children: [
            WidgetSpan(child: bubble, alignment: PlaceholderAlignment.middle),
          ],
        ),
      );
    }
    return null;
  }
}
