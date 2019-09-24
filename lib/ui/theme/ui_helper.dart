import 'package:flutter/material.dart';

/// Useful alignment consts to reduce boilerplate and duplicate code
class UIHelper {
    // Vertical spacing constants
    static const double _VerticalSpaceSmall = 8.0;
    static const double _VerticalSpaceMedium = 16.0;
    static const double _VerticalSpaceLarge = 32.0;
    static const double _VerticalSpaceXLarge = 64.0;

    // Horizontal spacing constants
    static const double _HorizontalSpaceSmall = 8.0;
    static const double _HorizontalSpaceMedium = 16.0;
    static const double _HorizontalSpaceLarge = 32.0;
    static const double _HorizontalSpaceXLarge = 64.0;

    static const Widget verticalSpaceSmall = SizedBox(height: _VerticalSpaceSmall);
    static const Widget verticalSpaceMedium = SizedBox(height: _VerticalSpaceMedium);
    static const Widget verticalSpaceLarge = SizedBox(height: _VerticalSpaceLarge);
    static const Widget verticalSpaceXLarge = SizedBox(height: _VerticalSpaceXLarge);

    static const Widget horizontalSpaceSmall = SizedBox(width: _HorizontalSpaceSmall);
    static const Widget horizontalSpaceMedium = SizedBox(width: _HorizontalSpaceMedium);
    static const Widget horizontalSpaceLarge = SizedBox(width: _HorizontalSpaceLarge);
    static const Widget horizontalSpaceXLarge = SizedBox(width: _HorizontalSpaceXLarge);
}
