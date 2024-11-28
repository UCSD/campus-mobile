import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/*
Widget used to Linkify text and then ensure any invalid URLs are caught and
reported to user. This should be used in place of the Linkify widget.
 */

class LinkifyWithCatch extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool looseUrl;

  const LinkifyWithCatch({
    Key? key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.looseUrl = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Linkify(
      onOpen: (link) async {
        try {
          await launch(link.url, forceSafariVC: true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not open.'),
          ));
        }
      },
      options: LinkifyOptions(humanize: false, looseUrl: looseUrl),
      text: text,
      textAlign: textAlign,
      style: style,
    );
  }
}
