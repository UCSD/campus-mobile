import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/chat_citation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onFeedbackSelected,
  });

  final AssistantChatMessage message;
  final void Function(String messageId, AssistantChatFeedback feedback) onFeedbackSelected;

  @override
  Widget build(BuildContext context) {
    return message.isFromUser ? _buildUserBubble(context) : _buildAssistantBubble(context);
  }

  Widget _buildUserBubble(BuildContext context) {
    final double maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F8),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              fontFamily: 'Brix Sans',
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: lightPrimaryColor,
              height: 1.28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              'assets/images/tgpt/tgpt-icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (message.text.isNotEmpty)
                MarkdownBody(
                  data: message.text,
                  shrinkWrap: true,
                  onTapLink: (_, String? href, __) {
                    if (href == null || href.isEmpty) return;
                    ChatCitation.openCitation(href);
                  },
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      fontFamily: 'Brix Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: lightPrimaryColor,
                      height: 1.4,
                    ),
                    listBullet: const TextStyle(
                      fontFamily: 'Brix Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: lightPrimaryColor,
                    ),
                    strong: const TextStyle(
                      fontFamily: 'Brix Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: lightPrimaryColor,
                    ),
                    a: const TextStyle(
                      fontFamily: 'Brix Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: linkTextColorLight,
                      decoration: TextDecoration.underline,
                    ),
                    blockSpacing: 6,
                  ),
                ),
              if (message.citations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.citations
                        .map(
                          (AssistantChatCitation citation) => ChatCitation(citation: citation),
                        )
                        .toList(),
                  ),
                ),
              if (!message.isStreaming && message.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _FeedbackButton(
                        icon: message.feedback == AssistantChatFeedback.upvote
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        isSelected: message.feedback == AssistantChatFeedback.upvote,
                        onTap: () => onFeedbackSelected(message.id, AssistantChatFeedback.upvote),
                      ),
                      const SizedBox(width: 2),
                      _FeedbackButton(
                        icon: message.feedback == AssistantChatFeedback.downvote
                            ? Icons.thumb_down_alt
                            : Icons.thumb_down_alt_outlined,
                        isSelected: message.feedback == AssistantChatFeedback.downvote,
                        onTap: () => onFeedbackSelected(message.id, AssistantChatFeedback.downvote),
                      ),
                    ],
                  ),
                ),
              if (message.isStreaming && message.text.isEmpty)
                const _TypingIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(3, (int i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double phase = (_controller.value - i * 0.18).clamp(0.0, 1.0);
              final double offset = phase < 0.5
                  ? -4.0 * (phase / 0.5)
                  : -4.0 * (1.0 - (phase - 0.5) / 0.5);
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 5),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFB0B5BE),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      icon: Icon(
        icon,
        size: 18,
        color: isSelected ? const Color(0xFF00629B) : const Color(0xFF8C9198),
      ),
    );
  }
}
