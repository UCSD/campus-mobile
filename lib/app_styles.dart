import 'package:flutter/material.dart';

/* Campus Mobile Style Guide (WIP)

// Apply Global Text Theme:
style: Theme.of(context).textTheme.bodySmall

// Apply Global Text Theme with Style Override:
style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  color: lightPrimaryColor,
)

// Apply Custom Text Theme:
style: Theme.of(context).brightness == Brightness.dark
            ? notificationsTitleDark
            : notificationsTitleLight
*/

/* START Global Themes Configured in main.dart */
// Primary Colors
const Color lightPrimaryColor = Color(0xFF182B49);
const Color darkPrimaryColor = Color(0xFF333333);
const Color darkPrimaryColor2 = Color(0xFFF5F0E6);
const Color darkPrimaryBgColor = Color(0xff1D1D1D);

const Color secondaryColorLight = Color(0xFF182B49);
const Color secondaryColorDark = Color(0xFF5496BC);

const Color linkTextColorLight = Color(0xFF00629B);
const Color linkTextColorDark = Color(0xFF5496BC);

const Color descriptiveTextColorLight = Color(0xFF6A6B6D);
const Color descriptiveTextColorDark = Color(0xFFA1A2A4);
const Color listTileDividerColorLight = Color(0xFF647185);
const Color listTileDividerColorDark = Color(0xFF647185);

const Color systemErrorTextColorLight = Color(0xFFAC1700);
const Color systemErrorTextColorDark = Color(0xFFAC1700);
const Color systemErrorBackground = Color(0xFFF8E8E6);

/* END Global Themes Configured in main.dart */

/* START Other Styles */
final descriptiveTextSmallLight = TextStyle(
  fontSize: 16.0,
  color: descriptiveTextColorLight,
);

final descriptiveTextSmallDark = TextStyle(
  fontSize: 16.0,
  color: descriptiveTextColorDark,
);

const headerStyle = TextStyle(
  fontFamily: 'Refrigerator Deluxe',
  fontSize: 35,
  fontWeight: FontWeight.w900,
);

const subHeaderStyle = TextStyle(
  fontFamily: 'Brix Sans',
  fontSize: 16.0,
  fontWeight: FontWeight.w500,
);

final textButtonSmallLight = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    color: linkTextColorLight,
    decoration: TextDecoration.underline);

final textButtonSmallDark = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    color: linkTextColorDark,
    decoration: TextDecoration.underline);

const titleSmallLight = TextStyle(
    fontFamily: 'Refrigerator Deluxe',
    fontSize: 18.0,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w900,
    color: lightPrimaryColor);

const titleSmallDark = TextStyle(
    fontFamily: 'Refrigerator Deluxe',
    fontSize: 18.0,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w900,
    color: Color(0xFFF5F0E6));

const titleMediumLight = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: lightPrimaryColor);

const titleMediumDark = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: Colors.white);

const headlineMediumLight = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    decoration: TextDecoration.underline,
    color: linkColorLight);

const headlineMediumDark = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    decoration: TextDecoration.underline,
    color: linkColorDark);

const headlineMediumLight2 = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: lightPrimaryColor);

const headlineMediumDark2 = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: darkPrimaryColor2);

const bodyMediumLight = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    color: descriptiveTextColorLight);

const bodyMediumDark = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    color: descriptiveTextColorDark);

const appBarTitleStyle = TextStyle(
  fontFamily: 'Refrigerator Deluxe',
  fontSize: 30,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

const cardTitleStyleLight = TextStyle(
    fontFamily: 'Refrigerator Deluxe',
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: lightPrimaryColor);

const cardTitleStyleDark = TextStyle(
  fontFamily: 'Refrigerator Deluxe',
  fontSize: 28,
  fontWeight: FontWeight.w900,
  color: darkPrimaryColor2,
);

const TextStyle labelLargeStyleLight = TextStyle(
  color: secondaryColorLight,
  fontFamily: 'Brix Sans',
  fontSize: 18,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
);

const TextStyle labelLargeStyleDark = TextStyle(
  color: secondaryColorDark,
  fontFamily: 'Brix Sans',
  fontSize: 18,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
);

const labelMediumStyleLight = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: descriptiveTextColorLight);

const labelMediumStyleDark = TextStyle(
    fontFamily: 'Brix Sans',
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: descriptiveTextColorDark);

const TextStyle notificationsTitleLight = TextStyle(
  color: linkTextColorLight,
  fontFamily: 'Brix Sans',
  fontSize: 18,
);

const TextStyle notificationsTitleDark = TextStyle(
  color: secondaryColorDark,
  fontFamily: 'Brix Sans',
  fontSize: 18,
);

const TextStyle textSubheaderLight = TextStyle(
  color: lightPrimaryColor,
  fontFamily: 'Brix Sans',
  fontSize: 22,
  height: 1.22,
);

const TextStyle textSubheaderDark = TextStyle(
  color: darkPrimaryColor2,
  fontFamily: 'Brix Sans',
  fontSize: 22,
  height: 1.22,
);

const textSmallMoreInfoLight = TextStyle(
    fontSize: 15.0, fontWeight: FontWeight.w700, color: lightPrimaryColor);

const textSmallMoreInfoDark = TextStyle(
    fontSize: 15.0, fontWeight: FontWeight.w700, color: darkPrimaryColor2);

// New custom styles for heading2
const TextStyle heading2StyleLight = TextStyle(
  fontFamily: 'Brix Sans',
  fontSize: 24.0,
  fontWeight: FontWeight.w500,
  color: lightPrimaryColor,
);

const TextStyle heading2StyleDark = TextStyle(
  fontFamily: 'Brix Sans',
  fontSize: 24.0,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);

const TextStyle linkTextDark = TextStyle(
    fontFamily: 'Brix Sans',
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.underline,
    color: linkColorDark);

const TextStyle linkTextLight = TextStyle(
    fontFamily: 'Brix Sans',
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.underline,
    color: linkColorLight);

const Color toggleActiveColor = Color(0xFF109B00);

// Theme agnostic styles
const agnosticDisabled = Color(0xFF8A8A8A);

// Card Layout
const cardMargin = 8.0;
const cardPaddingInner = 8.0;
const cardMinHeight = 60.0;

// Card Heights
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

// Color for the top App Bar on light theme
const AppBarTheme lightAppBarTheme = AppBarTheme(color: ColorPrimary);

// Color for the top App Bar on dark theme
const AppBarTheme darkAppBarTheme = AppBarTheme(color: ColorPrimary);

// Icon color for light theme
const IconThemeData lightIconTheme = IconThemeData(color: lightPrimaryColor);

// Icon color for dark theme
const IconThemeData darkIconTheme = IconThemeData(color: darkPrimaryColor2);

// Unselected / inactive colors
const Color unselectedIconLightColor = Color(0xFF6A6B6D);
const Color unselectedIconDarkColor = Color(0xFF6A6B6D);

// Colors for text on buttons using light theme
const TextTheme lightThemeText = TextTheme(
  labelLarge: TextStyle(color: lightTextColor, fontSize: 20),
);

// Colors for text on buttons using dark theme
const TextTheme darkThemeText = TextTheme(
  labelLarge: TextStyle(color: darkTextColor, fontSize: 20),
);

// Button color for themes
const Color lightButtonColor = Color(0xFF034263);
const Color lightButtonTextColor = Color(0xFF000000);
const Color lightButtonBorderColor = Color(0xFFFFFFFF);
const Color darkButtonColor = Color(0xFFFFFFFF);

// Colors
const Color lightTextColor = Color(0xFFFFFFFF);
const Color darkTextColor = Color(0xFF006A96);
const Color actionButtonBackgroundColor = Color(0xFFFFCD00);
const Color dotsUnselectedColor = Color(0xFF747678);
const Color dotsSelectedColorLight = Color(0xFF00629B);
const Color dotsSelectedColorDark = Color(0xFF5496BC);
const Color linkColorLight = Color(0xFF00629B);
const Color linkColorDark = Color(0xFF5496BC);
const Color bottomTabBarColorLight = Color(0xFFFBF9F5);
const Color bottomTabBarColorDark = Color(0xFF404142);

// Text Field colors for themes
const Color lightTextFieldBorderColor = Color(0xFFFFFFFF);

// Accent colors for themes
const Color lightAccentColor = Color(0xFFFFFFFF);
const Color darkAccentColor = Color(0xFF333333);

// Universal color for themes
const Color ucLabelColor = Color(0xFF777777);

const debugHeader = TextStyle(color: lightTextColor, fontSize: 14.0);
const debugRow = TextStyle(color: lightTextColor, fontSize: 12.0);

// Testing
const Color c1 = Color.fromARGB(255, 255, 0, 0);
const Color c2 = Color.fromARGB(255, 0, 255, 0);
const Color c3 = Color.fromARGB(255, 0, 0, 255);

// List Tile Theme Data
const lightListTileTheme =
    ListTileThemeData(selectedColor: const Color(0xFF00629B));
const darkListTileTheme =
    ListTileThemeData(selectedColor: const Color(0xFF00C6D7));

// New Onboarding Screen Colors
const lightOnboardingScreen = Color.fromARGB(255, 245, 240, 228);
