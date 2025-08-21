import 'package:flutter/material.dart';

class ActionLink extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const ActionLink({
    Key? key,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.transparent),
        alignment: Alignment.bottomCenter,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Text(
          buttonText,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                decoration: TextDecoration.underline,
              ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
