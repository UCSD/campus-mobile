import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';

import 'package:provider/provider.dart';

class ScannerCard extends StatelessWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: true,
      hide: () => null,
      reload: () => null,
      isLoading: false,
      title: buildTitle(),
      errorText: null,
      child: () => buildCardContent(context),
      actionButtons: [buildActionButton(context)],
      hideMenu: true,
    );
  }

  Widget buildTitle() {
    return Text(
      "QR Scanner",
      textAlign: TextAlign.left,
    );
  }

  Widget buildCardContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("tappy tap tap");
        getActionButtonNavigateRoute(context);
      },
      behavior: HitTestBehavior.translucent,
        child: Row(
          children: <Widget>[
            Container(
              child: Image.asset(
                'assets/images/QRScanIcon.png',
                fit: BoxFit.contain,
                height: 56,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            ),
            Text(
              getCardContentText(context),
              textAlign: TextAlign.left,
            )
          ],
        ),
    );
  }

  Widget buildActionButton(BuildContext context) {
    return FlatButton(
      child: Text(
        getActionButtonText(context),
      ),
      onPressed: () {
        getActionButtonNavigateRoute(context);
      },
    );
  }

  String getCardContentText(BuildContext context) {
    return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
        ? 'Scan Your COVID-19 Test Kit.'
        : ButtonText.SignIn + ' Scan Your COVID-19 Test Kit.';
  }

  String getActionButtonText(BuildContext context) {
    return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
        ? ButtonText.ScanNow
        : ButtonText.SignIn;
  }

  getActionButtonNavigateRoute(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      Navigator.pushNamed(
        context,
        RoutePaths.ScannerView,
      );
    } else {
      Provider.of<BottomNavigationBarProvider>(context, listen: false)
          .currentIndex = NavigationConstants.ProfileTab;
    }
  }
}
