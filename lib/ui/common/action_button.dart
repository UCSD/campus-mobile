import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(
            const Color(0xFFFFCD00)), // Fixed background color
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        alignment: Alignment.bottomCenter,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 24), // Fixed padding
        child: Text(buttonText, style: Theme.of(context).textTheme.labelLarge),
      ),
      onPressed: onPressed,
    );
  }
}
