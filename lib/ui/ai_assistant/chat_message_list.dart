import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/chat_message_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
  });

  final List<AssistantChatMessage> messages;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scheduleScrollToBottom();
  }

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool didChangeLength = oldWidget.messages.length != widget.messages.length;
    final bool didChangeLastMessage = !didChangeLength &&
        widget.messages.isNotEmpty &&
        oldWidget.messages.isNotEmpty &&
        oldWidget.messages.last.text != widget.messages.last.text;

    if (didChangeLength || didChangeLastMessage) _scheduleScrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      itemCount: widget.messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (BuildContext context, int index) {
        return ChatMessageBubble(
          message: widget.messages[index],
        );
      },
    );
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var isUnmounted = !mounted;
      var hasNoClients = !_scrollController.hasClients;
      if (isUnmounted || hasNoClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}
