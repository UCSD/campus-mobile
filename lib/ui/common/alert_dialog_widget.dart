import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class AlertDialogWidget extends StatelessWidget {
  final int type;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onClose;

  const AlertDialogWidget({
    Key? key,
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final successAlertDialogLightTheme = ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorPrimary).copyWith(
        primary: Color(0xFF0B6E00), // Error color
        surface: Color(0xFFE7F5E6), // Light error background
        brightness: Brightness.light,
      ),
    );

    final infoAlertDialogLightTheme = ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorPrimary).copyWith(
        primary: Color(0xFF00629B), // Error color
        surface: Color(0xFFE6EFF5), // Light error background
        brightness: Brightness.light,
      ),
    );

    final warningAlertDialogLightTheme = ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorPrimary).copyWith(
        primary: Color(0xFF975200), // Error color
        surface: Color(0xFFFFF3E6), // Light error background
        brightness: Brightness.light,
      ),
    );

    final errorAlertDialogLightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorPrimary).copyWith(
        primary: Color(0xFFAC1700), // Error color
        surface: Color(0xFFF8E8E6), // Light error background
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: type == MessageTypeConstants.ERROR
          ? errorAlertDialogLightTheme
          : successAlertDialogLightTheme, // Apply the error theme
      child: AlertDialog(
        titlePadding: EdgeInsets.fromLTRB(5, 5, 0, 0),
        contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 20),
        backgroundColor: errorAlertDialogLightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: errorAlertDialogLightTheme.colorScheme.primary),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Icon(icon, color: errorAlertDialogLightTheme.colorScheme.primary),
              flex: 1,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: errorAlertDialogLightTheme.colorScheme.primary,
                  fontFamily: 'Brix Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18.0,
                ),
              ),
              flex: 7,
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.close, color: errorAlertDialogLightTheme.colorScheme.primary),
                alignment: Alignment.topRight,
                onPressed: onClose,
              ),
              flex: 2,
            ),
          ],
        ),
        content: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        description,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: errorAlertDialogLightTheme.colorScheme.primary,
                          fontFamily: 'Source Sans Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
