import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssistantHeader extends StatelessWidget {
  const AssistantHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safeAreaInsets = MediaQuery.paddingOf(context);

    return Container(
      width: double.infinity,
      color: lightPrimaryColor,
      padding: EdgeInsets.fromLTRB(24, safeAreaInsets.top + 14, 24, 16),
      child: Center(child: SvgPicture.asset('assets/images/tgpt/tritongpt-header.svg', height: 27)),
    );
  }
}
