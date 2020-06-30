import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/*
Widget used to Linkify text and then ensure any invalid URLs are caught and
reported to user. This should be used in place of the Linkify widget.
 */

class LinkifyWithCatch extends StatelessWidget {
  final String text;
  final TextStyle style;

  const LinkifyWithCatch({Key key, @required this.text, @required this.style})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Linkify(
      onOpen: (link) async {
        try {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        } catch (e) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Could not open.'),
          ));
        }
      },
      options: LinkifyOptions(humanize: false),
      text: text,
      style: style,
    );
  }
}
