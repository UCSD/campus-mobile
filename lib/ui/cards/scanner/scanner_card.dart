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
      active: Provider.of<UserDataProvider>(context).cardStates['scanner'],
      hide: () => Provider.of<UserDataProvider>(context, listen: false)
          .toggleCard('scanner'),
      reload: () => null,
      isLoading: false,
      title: buildTitle(),
      errorText: '',
      child: () => buildCardContent(context),
      actionButtons: [buildActionButton(context)],
    );
  }

  Widget buildTitle() {
    return Text(
      "Scanner",
      textAlign: TextAlign.left,
    );
  }

  Widget buildCardContent(BuildContext context) {
    return Column();
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

  String getActionButtonText(BuildContext context) {
    return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn ?
      ButtonText.ScanNow : ButtonText.SignIn;
  }

  getActionButtonNavigateRoute(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      Navigator.pushNamed(
        context,
        RoutePaths.ScannerView,
      );
    }
    else {
      Provider.of<BottomNavigationBarProvider>(context, listen: false)
          .updateCurrentIndex(NavigationConstants.ProfileTab, NavigationConstants.ScannerLogin);
    }
  }
}
