import 'package:flutter/material.dart';

/// App Styles
const headerStyle = TextStyle(fontSize: 35, fontWeight: FontWeight.w900);
const subHeaderStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500);

// Theme agnostic styles
const agnosticDisabled = Color(0xFF8A8A8A);

/// App Layout
// Card Layout
const cardMargin = 6.0;
const cardPaddingInner = 8.0;
const cardMinHeight = 60.0;
const listTileInnerPadding = 8.0;

//Card Heights
const cardContentMinHeight = 80.0;
const cardContentMaxHeight = 568.0;

const webViewMinHeight = 20.0;

/// App Theme
const MaterialColor ColorPrimary = MaterialColor(
  0xFF182B49,
  <int, Color>{
    50: Color(0xFF182B49),
    100: Color(0xFF182B49),
    200: Color(0xFF182B49),
    300: Color(0xFF182B49),
    400: Color(0xFF182B49),
    500: Color(0xFF182B49),
    600: Color(0xFF182B49),
    700: Color(0xFF182B49),
    800: Color(0xFF182B49),
    900: Color(0xFF182B49),
  },
);

const MaterialColor ColorSecondary = MaterialColor(
  0xFF006A96,
  <int, Color>{
    50: Color(0xFF006A96),
    100: Color(0xFF006A96),
    200: Color(0xFF006A96),
    300: Color(0xFF006A96),
    400: Color(0xFF006A96),
    500: Color(0xFF006A96),
    600: Color(0xFF006A96),
    700: Color(0xFF006A96),
    800: Color(0xFF006A96),
    900: Color(0xFF006A96),
  },
);

const Color lightPrimaryColor = Color(0xFF182B49);
const Color darkPrimaryColor = Color(0xFF333333);

//Color for the top App Bar on light theme
const AppBarTheme lightAppBarTheme = AppBarTheme(color: ColorPrimary);

//Color for the top App Bar on dark theme
const AppBarTheme darkAppBarTheme = AppBarTheme(
  color: ColorPrimary,
);

//Icon color for light theme
const IconThemeData lightIconTheme = IconThemeData(
  color: Color(0xFF0D47A1),
);

//Icon color for dark theme
const IconThemeData darkIconTheme = IconThemeData(
  color: Color(0xFFFFFFFF),
);

//Colors for text on buttons using light theme
const TextTheme lightThemeText = TextTheme(
  button: TextStyle(
    color: lightTextColor,
  ),
);

//Colors for text on buttons using dark theme
const TextTheme darkThemeText = TextTheme(
  button: TextStyle(color: darkTextColor),
);

//Button color for themes
const Color lightButtonColor = Color(0xFF034263);
const Color lightButtonTextColor = Color(0xFF000000);
const Color lightButtonBorderColor = Color(0xFFFFFFFF);
const Color darkButtonColor = Color(0xFFFFFFFF);

//Colors
const Color lightTextColor = Color(0xFFFFFFFF);
const Color darkTextColor = Color(0xFF006A96);

//Text Field colors for themes
const Color lightTextFieldBorderColor = Color(0xFFFFFFFF);

//Accent colors for themes
const Color lightAccentColor = Color(0xFFFFFFFF);
const Color darkAccentColor = Color(0xFF333333);

const debugHeader = TextStyle(color: lightTextColor, fontSize: 14.0);
const debugRow = TextStyle(color: lightTextColor, fontSize: 12.0);

// Testing
const Color c1 = Color.fromARGB(255, 255, 0, 0);
const Color c2 = Color.fromARGB(255, 0, 255, 0);
const Color c3 = Color.fromARGB(255, 0, 0, 255);
