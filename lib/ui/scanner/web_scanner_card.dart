import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String cardId = 'QRScanner';

class ScannerCard extends StatelessWidget {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getCardContentText(context),
                textAlign: TextAlign.left,
              ),
              getMessageWidget(context),
            ],
          ),
        ],
      ),
    );
  }

  final _url =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/scanner/index.html';

  UserDataProvider _userDataProvider;

  Widget buildActionButton(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    return TextButton(
      child: Text(
        getActionButtonText(context),
      ),
      onPressed: () {
        getActionButtonNavigateRoute(context);
      },
    );
  }

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
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

  getActionButtonNavigateRoute(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      generateScannerUrl();
    } else {
      Provider.of<BottomNavigationBarProvider>(context, listen: false)
          .currentIndex = NavigatorConstants.ProfileTab;
    }
  }

  generateScannerUrl() {
    var tokenQueryString =
        "token=" + '${_userDataProvider.authenticationModel.accessToken}';
    var affiliationQueryString = "affiliation=" +
        '${_userDataProvider.authenticationModel.ucsdaffiliation}';
    var url = _url + "?" + tokenQueryString + "&" + affiliationQueryString;

    openLink(url);
  }

  Widget getMessageWidget(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn &&
        Provider.of<ScannerMessageDataProvider>(context, listen: false)
                .scannerMessageModel
                .collectionTime !=
            null) {
      return (Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Last scan: ",
              ),
              TextSpan(
                  text: Provider.of<ScannerMessageDataProvider>(context,
                          listen: false)
                      .scannerMessageModel
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
}
