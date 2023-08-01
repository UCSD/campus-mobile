import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/scanner.dart';
import 'package:campus_mobile_experimental/core/providers/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'NativeScanner';

class NativeScannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: true,
      hide: () => null,
      reload: () =>
          Provider.of<ScannerMessageDataProvider>(context, listen: false)
              .fetchData(),
      isLoading: Provider.of<ScannerMessageDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
      actionButtons: [buildActionButton(context)],
      hideMenu: false,
    );
  }

  Widget buildCardContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getCardContentText(context),
                  textAlign: TextAlign.left,
                ),
                getMessageWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
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
        ? ButtonText.ScanNowFull
        : ButtonText.SignInFull;
  }

  String getActionButtonText(BuildContext context) {
    return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
        ? ButtonText.ScanNow
        : ButtonText.SignIn;
  }

  Widget getMessageWidget(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      String? myRecentScanTime =
          Provider.of<ScannerMessageDataProvider>(context, listen: false)
              .scannerMessageModel!
              .collectionTime;
      if (myRecentScanTime == "") {
        myRecentScanTime = ScannerConstants.noRecentScan;
      }
      return (Padding(
        padding: EdgeInsets.only(top: 8.0, right: 8.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Last test kit scan: ",
              ),
              TextSpan(
                  text: Provider.of<ScannerMessageDataProvider>(context,
                          listen: false)
                      .scannerMessageModel!
                      .collectionTime,
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ));
    } else {
      return Container(width: 0, height: 0);
    }
  }

  getActionButtonNavigateRoute(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      Provider.of<ScannerDataProvider>(context, listen: false)
          .setDefaultStates();
      Navigator.pushNamed(
        context,
        RoutePaths.ScanditScanner,
      );
    } else {
      Provider.of<BottomNavigationBarProvider>(context, listen: false)
          .currentIndex = NavigatorConstants.ProfileTab;
      Provider.of<CustomAppBar>(context, listen: false).changeTitle("Profile");
    }
  }
}
