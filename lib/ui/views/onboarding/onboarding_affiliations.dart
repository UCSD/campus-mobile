import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingAffiliations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ColorPrimary,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
                "Your affiliation with UC San Diego",
                style: TextStyle(color: lightTextColor)
            ),
            FlatButton(
              onPressed: () {  },
              child: Text(
                  "Student",
                style: TextStyle(color: lightTextColor)
              )
            ),
            FlatButton(
                onPressed: () {  },
                child: Text(
                    "Staff/Faculty",
                    style: TextStyle(color: lightTextColor)
                )            ),
            FlatButton(
                onPressed: () {  },
                child: Text(
                    "Visitor",
                    style: TextStyle(color: lightTextColor)
                )            ),
          ],
        ),
      ),
    );
  }
}
