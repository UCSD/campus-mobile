import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatCitation extends StatelessWidget {
  const ChatCitation({
    super.key,
    required this.citation,
  });

  final ChatCitationReference citation;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openCitation(context, citation.url),
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

  /// Opens [url] in an in-app [CitationWebView] so the app bar title is **CITATION**.
  ///
  /// Ignores fragment-only placeholders (e.g. `[text](#rq)` from Related Questions) and
  /// any string that is not a navigable `http`/`https` URL after resolution.
  static Future<void> openCitation(BuildContext context, String url) async {
    final String trimmed = url.trim();
    if (trimmed.isEmpty) return;
    // Related-question / UI placeholders from model markdown — not real URLs.
    if (trimmed.startsWith('#')) return;
    if (trimmed.toLowerCase().startsWith('javascript:')) return;

    String resolved = trimmed;
    if (trimmed.startsWith('//')) {
      resolved = 'https:$trimmed';
    } else {
      final Uri parsed = Uri.tryParse(trimmed) ?? Uri();
      if (!parsed.hasScheme && trimmed.contains('.')) {
        resolved = 'https://$trimmed';
      }
    }

    final Uri? uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme) return;
    if (uri.scheme != 'http' && uri.scheme != 'https') return;

    await Navigator.of(context).pushNamed(
      RoutePaths.TGPT_CITATION_WEB,
      arguments: resolved,
    );
  }
}
