import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/chat_citation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final AssistantChatMessage message;

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
    final AssistantMessageContent content = message.content;

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
              if (content.markdown.isNotEmpty)
                MarkdownBody(
                  data: content.markdown,
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
                          (ChatCitationReference citation) => ChatCitation(citation: citation),
                        )
                        .toList(),
                  ),
                ),
              if (content.relatedQuestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _RelatedQuestionsSection(questions: content.relatedQuestions),
                ),
              if (message.isStreaming && content.markdown.isEmpty && content.relatedQuestions.isEmpty)
                const _TypingIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}

class _RelatedQuestionsSection extends StatelessWidget {
  const _RelatedQuestionsSection({
    required this.questions,
  });

  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE1E6EE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Related Questions',
            style: TextStyle(
              fontFamily: 'Brix Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: lightPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...questions.map(
            (String question) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '•',
                      style: TextStyle(
                        fontFamily: 'Brix Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: lightPrimaryColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontFamily: 'Brix Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: lightPrimaryColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              final double offset = phase < 0.5 ? -4.0 * (phase / 0.5) : -4.0 * (1.0 - (phase - 0.5) / 0.5);
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
