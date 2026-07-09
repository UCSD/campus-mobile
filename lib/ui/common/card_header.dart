import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.titleText,
    required this.trailing,
    this.padding = const EdgeInsets.only(top: 0.0, right: 8.0, bottom: 0.0, left: 8.0),
  });

  final String titleText;
  final Widget trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Semantics(
        explicitChildNodes: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                container: true,
                header: true,
                focusable: true,
                child: Text(
                  titleText,
                  style: Theme.of(context).textTheme.titleLarge,
                  semanticsLabel: '$titleText Card Heading',
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
