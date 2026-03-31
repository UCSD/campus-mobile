import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? trailingIcon;

  const ActionButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: lightPrimaryColor,
      fontFamily: 'Brix Sans',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(actionButtonBackgroundColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        alignment: Alignment.centerLeft,
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: actionButtonHorizontalPadding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(buttonText, style: textStyle),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 18, color: lightPrimaryColor),
            ],
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
