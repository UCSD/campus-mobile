import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Legacy widget for rendering markdown-style citations as tappable links in chat messages
/// Not used in current chatbot UI; citation handling is now integrated into assistant.dart
/// If you want to use custom citation rendering, you could adapt this logic for RichText/Markdown
class CitationText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CitationText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pattern = RegExp(r'\\[(\\d+)\\]\\(([^)]+)\\)');
    final lines = text.split('\n');
    final widgets = <Widget>[];
    for (final line in lines) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('• ')) {
        // Bullet line: use Row for hanging indent
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24), // indent for bullet
              Text('• ', style: style),
              Expanded(
                child: _buildRichTextWithCitations(trimmed.substring(2), style, pattern),
              ),
            ],
          ),
        );
      } else {
        widgets.add(_buildRichTextWithCitations(line, style, pattern));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // Helper for building RichText with clickable citation links
  Widget _buildRichTextWithCitations(String text, TextStyle? style, RegExp pattern) {
    final spans = <TextSpan>[];
    int last = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > last) {
        spans.add(
          TextSpan(
            text: text.substring(last, match.start),
            style: style,
          ),
        );
      }
      final num = match.group(1)!;
      final url = match.group(2)!;
      spans.add(
        TextSpan(
          text: '[$num]',
          style: style?.copyWith(color: Colors.blue, decoration: TextDecoration.underline) ??
              const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse(url));
            },
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(last),
          style: style,
        ),
      );
    }
    return RichText(
      text: TextSpan(children: spans, style: style),
      textAlign: TextAlign.start,
      textWidthBasis: TextWidthBasis.parent,
    );
  }
}
