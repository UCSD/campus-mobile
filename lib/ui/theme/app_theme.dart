import 'package:flutter/material.dart';

// Primary Color
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

// Secondary Color
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

//Color for the top App Bar on light theme
const AppBarTheme lightAppBarTheme = AppBarTheme(
  color: Color(0xFF034262),
);

//Color for the top App Bar on dark theme
const AppBarTheme darkAppBarTheme = AppBarTheme(
  color: Color(0xFF034262),
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
    color: Color(0xFFFFFFFF),
  ),
);

//Colors for text on buttons using dark theme
const TextTheme darkThemeText = TextTheme(
  button: TextStyle(
    color: Color(0xFF006A96),
  ),
);

//Button color for themes
const Color lightButtonColor = Color(0xFF034263);
const Color lightButtonTextColor = Color(0xFFFFFFFF);
const Color lightButtonBorderColor = Color(0xFFFFFFFF);
const Color darkButtonColor = Color(0xFFFFFFFF);

///Text Field colors for themes
const Color lightTextFieldBorderColor = Color(0xFFFFFFFF);

//Accent colors for themes
const Color lightAccentColor = Color(0xFFFFFFFF);
const Color darkAccentColor = Color(0xFFAFA9A0);

// Testing
const Color c1 = Color.fromARGB(255, 255, 0, 0);
const Color c2 = Color.fromARGB(255, 0, 255, 0);
const Color c3 = Color.fromARGB(255, 0, 0, 255);
