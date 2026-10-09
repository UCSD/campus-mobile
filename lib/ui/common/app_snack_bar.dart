import 'package:flutter/material.dart';

abstract final class AppSnackBar {
  static const theme = SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    contentTextStyle: TextStyle(color: Colors.white),
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );

  static void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}
