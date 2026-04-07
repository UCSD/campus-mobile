import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatCitation extends StatelessWidget {
  const ChatCitation({
    super.key,
    required this.citation,
  });

  final AssistantChatCitation citation;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openCitation(citation.url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD7DDE5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/tgpt/document_icon.svg',
              width: 16,
              height: 14,
            ),
            const SizedBox(width: 6),
            Text(
              '[${citation.number}]',
              style: const TextStyle(
                fontFamily: 'Brix Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF182B49),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> openCitation(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
