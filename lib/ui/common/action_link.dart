import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';

class ActionLink extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const ActionLink({Key? key, required this.buttonText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.transparent),
        alignment: Alignment.centerLeft,
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: actionButtonHorizontalPadding),
        child: Text(
          buttonText,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(decoration: TextDecoration.underline),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
