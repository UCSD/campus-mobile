import 'dart:ui';

import 'package:campus_mobile_experimental/core/providers/chat_provider.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant_empty_state.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant_header.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant_sidebar.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/chat_composer.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/chat_message_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AIAssistantView extends StatefulWidget {
  const AIAssistantView({super.key});

  @override
  State<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends State<AIAssistantView> {
  static const Color _SIDEBAR_ICON_COLOR = Color(0xFF747678);
  static const Color _NEW_CHAT_ICON_COLOR = Color(0xFF00629B);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarOpen = false;
  ChatProvider? _chatProvider;
  UserDataProvider? _userDataProvider;
  bool? _lastObservedLoginState;
  String? _lastShownError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ChatProvider nextChatProvider = context.read<ChatProvider>();
    if (!identical(_chatProvider, nextChatProvider)) {
      _chatProvider?.removeListener(_handleChatProviderChanged);
      _chatProvider = nextChatProvider;
      _chatProvider?.addListener(_handleChatProviderChanged);
      _handleChatProviderChanged();
    }

    final UserDataProvider nextUserDataProvider = context.read<UserDataProvider>();
    if (!identical(_userDataProvider, nextUserDataProvider)) {
      _userDataProvider?.removeListener(_handleUserDataChanged);
      _userDataProvider = nextUserDataProvider;
      _lastObservedLoginState = nextUserDataProvider.isLoggedIn;
      _userDataProvider?.addListener(_handleUserDataChanged);
    }
  }

  @override
  void dispose() {
    _chatProvider?.removeListener(_handleChatProviderChanged);
    _userDataProvider?.removeListener(_handleUserDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = context.watch<ChatProvider>();
    final bool isLoggedIn = context.watch<UserDataProvider>().isLoggedIn;

    return PopScope(
      canPop: !_isSidebarOpen,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !_isSidebarOpen) return;
        _scaffoldKey.currentState?.closeDrawer();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawerScrimColor: Colors.black.withValues(alpha: 0.28),
        onDrawerChanged: (bool isOpen) {
          if (_isSidebarOpen == isOpen) return;
          setState(() {
            _isSidebarOpen = isOpen;
          });
        },
        drawer: AssistantSidebar(
          isLoggedIn: isLoggedIn,
          sessions: chatProvider.sessions,
          activeSessionId: chatProvider.activeSessionId,
          onNewChat: () async {
            Navigator.of(context).pop();
            await chatProvider.startNewChat();
          },
          onSelectSession: (String sessionId) async {
            Navigator.of(context).pop();
            await chatProvider.openSession(sessionId);
          },
          onClose: () => Navigator.of(context).pop(),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AbsorbPointer(
              absorbing: _isSidebarOpen,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _isSidebarOpen ? 8 : 0,
                  sigmaY: _isSidebarOpen ? 8 : 0,
                ),
                child: _buildMainContent(chatProvider),
              ),
            ),
            if (_isSidebarOpen)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0xFF182B49).withValues(alpha: 0.10),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ChatComposer(
            enabled: !chatProvider.isInitializing,
            isSending: chatProvider.isStreaming,
            onSubmitted: chatProvider.sendMessage,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ChatProvider chatProvider) {
    return Column(
      children: <Widget>[
        const AssistantHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                splashRadius: 22,
                icon: SvgPicture.asset(
                  'assets/images/tgpt/unpin-sidebar.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(_SIDEBAR_ICON_COLOR, BlendMode.srcIn),
                ),
              ),
              IconButton(
                onPressed: chatProvider.startNewChat,
                splashRadius: 22,
                icon: SvgPicture.asset(
                  'assets/images/tgpt/new_chat2.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(_NEW_CHAT_ICON_COLOR, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              chatProvider.hasMessages ? ChatMessageList(messages: chatProvider.messages) : const AssistantEmptyState(),
        ),
      ],
    );
  }

  void _handleChatProviderChanged() {
    final String? errorMessage = _chatProvider?.errorMessage;
    var hasErrorMessage = errorMessage != null && errorMessage.isNotEmpty;
    if (!hasErrorMessage) {
      _lastShownError = null;
      return;
    }
    if (errorMessage == _lastShownError) return;

    _lastShownError = errorMessage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    });
  }

  void _handleUserDataChanged() {
    final ChatProvider? chatProvider = _chatProvider;
    final UserDataProvider? userDataProvider = _userDataProvider;
    if (chatProvider == null || userDataProvider == null) return;

    final bool isLoggedIn = userDataProvider.isLoggedIn;
    if (_lastObservedLoginState == isLoggedIn) return;

    _lastObservedLoginState = isLoggedIn;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var isUnmounted = !mounted;
      var isChatProviderChanged = !identical(chatProvider, _chatProvider);
      if (isUnmounted || isChatProviderChanged) return;
      chatProvider.syncLoginState(isLoggedIn);
    });
  }
}
