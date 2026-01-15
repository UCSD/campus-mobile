import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:campus_mobile_experimental/core/services/chat_session_creation.dart';
import 'package:campus_mobile_experimental/core/services/chat_send_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

// Main UI for the chatbot (AI Assistant tab)
// Handles session initialization, message sending, and rendering the chat interface
// All chat history is stored in RAM in _messages; not persisted to disk or backend
// If you want persistent history, you would need to implement local storage (e.g., SQLite, Hive, shared_preferences)
// Session ID is created when the user enters the chatbot UI and is used for all subsequent messages
// Session expiration is managed by backend (dev3), not by this code
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = []; // In-memory chat history; cleared on tab switch or refresh
  final _user = types.User(id: 'user-id'); // Represents the current user in chat UI
  late String _chatSessionId; // Stores session ID for current chat session
  late ChatSessionService _chatSessionService;
  late ChatMessageService _chatMessageService;
  late UserDataProvider _userDataProvider;
  late bool _isLoadingSession = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    _chatSessionService = ChatSessionService(_userDataProvider);
    _chatMessageService = ChatMessageService(_userDataProvider);
    _initializeChatSession(); // Create session when UI loads
  }

  // Initializes chat session by calling ChatSessionService
  // Session ID is returned and stored for future messages
  // If session creation fails, shows error message
  Future<void> _initializeChatSession() async {
    setState(() => _isLoadingSession = true);
    if (_userDataProvider.isLoggedIn) {
      final session = await _chatSessionService.createChatSession();
      if (session != null) {
        setState(() {
          _chatSessionId = session.chatSessionId;
          _isLoadingSession = false;
        });
      } else {
        setState(() => _isLoadingSession = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create chat session')));
      }
    } else {
      setState(() => _isLoadingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Chat(
        messages: _messages, // All chat history is held in RAM here
        onSendPressed: _handleSendPressed, // Handles sending new messages
        user: _user,

        /// Custom builder for rendering markdown, citations, and links in chat messages
        textMessageBuilder: (
          types.TextMessage message, {
          required int messageWidth,
          required bool showName,
        }) {
          final isUser = message.author.id == _user.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
                listBullet: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
              builders: {
                'citation': CitationMarkdownBuilder(isUser: isUser), // Handles clickable citations
              },
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                [
                  CitationInlineSyntax(),
                  ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                ],
              ),
            ),
          );
        },

        theme: DefaultChatTheme(
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),

          // user bubble style
          primaryColor: const Color.fromARGB(255, 191, 12, 12),
          sentMessageBodyTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),

          // assistant bubble style
          secondaryColor: Colors.white,
          receivedMessageBodyTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),

          // BIGGER padding inside each bubble
          messageBorderRadius: 16,
          messageInsetsHorizontal: 32,
          messageInsetsVertical: 48,

          // input field (unchanged)
          inputTextCursorColor: Colors.red,
          inputBackgroundColor: Colors.white,
          inputTextColor: Colors.black,
          inputMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          inputTextStyle: const TextStyle(color: Colors.black),
          inputBorderRadius: const BorderRadius.horizontal(
            left: Radius.circular(10),
            right: Radius.circular(10),
          ),
          inputContainerDecoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
              right: Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: UniqueKey().toString(),
      text: message.text,
    );
    _addMessage(userMessage);

    final resp = await _chatMessageService.sendMessage(
      message: message.text,
      chatSessionId: _chatSessionId,
    );

    if (resp != null) {
      final botMessage = types.TextMessage(
        author: types.User(id: 'assistant-id'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: UniqueKey().toString(),
        text: resp.answer ?? 'No response from the assistant.',
      );
      _addMessage(botMessage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${_chatMessageService.error ?? "unknown error"}')),
      );
    }
  }

  void _addMessage(types.Message m) {
    setState(() => _messages.insert(0, m));
  }
}

class CitationInlineSyntax extends md.InlineSyntax {
  // Match [1](url) or [[1]](url)
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
      return RichText(
        text: TextSpan(
          text: '[$num]',
          style: (preferredStyle ??
                  TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                  ))
              .copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: url != null
              ? (TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse(url));
                })
              : null,
        ),
      );
    }
    return null;
  }
}
