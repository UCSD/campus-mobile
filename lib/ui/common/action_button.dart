import 'package:campus_mobile_experimental/app_styles.dart';
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
        backgroundColor: WidgetStatePropertyAll<Color>(actionButtonBackgroundColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        alignment: Alignment.bottomCenter,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Text(buttonText,
            style: TextStyle(
              color: lightPrimaryColor,
              fontFamily: 'Brix Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            )),
      ),
      onPressed: onPressed,
    );
  }
}
