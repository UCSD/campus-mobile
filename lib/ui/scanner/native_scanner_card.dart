import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/scanner_message.dart';
import 'package:campus_mobile_experimental/core/hooks/bottom_nav_query.dart';
import 'package:campus_mobile_experimental/core/providers/scanner.dart';
import 'package:campus_mobile_experimental/core/hooks/scanner_message_query.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import '../../core/providers/user.dart';

const String cardId = 'NativeScanner';

class NativeScannerCard extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final userDataProvider = useMemoized(() {
      debugPrint("Memoized UserDataProvider!");
      return Provider.of<UserDataProvider>(context);
    }, [context]);

    ///Fix when migrating UserDataProvider
    if (userDataProvider.authenticationModel?.accessToken == null) {
      return CardContainer(
        active: false,
        isLoading: true,
        hide: () => null,
        reload: () => null,
        titleText: '',
        errorText: '',
        child: () => Container(),
      );
    } else {
      final accessToken = userDataProvider.authenticationModel?.accessToken!;

      final scannerHook = useFetchScannerMessage(accessToken!);
      return CardContainer(
        active: true,
        hide: () => null,
        reload: () => scannerHook.refetch(),
        isLoading: scannerHook.isFetching || scannerHook.isLoading,
        titleText: CardTitleConstants.titleMap[cardId],
        errorText: scannerHook.isError ? "" : null,
        child: () => buildCardContent(scannerHook.data!, context),
        actionButtons: [buildActionButton(context)],
        hideMenu: false,
      );
    }
  }

  Widget buildCardContent(
      ScannerMessageModel scannerMessage, BuildContext context) {
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
                getMessageWidget(scannerMessage, context),
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
        foregroundColor: Theme.of(context).backgroundColor,
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

  Widget getMessageWidget(
      ScannerMessageModel scannerMessage, BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      String? myRecentScanTime = scannerMessage.collectionTime;
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
                  text: scannerMessage!.collectionTime,
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
      setBottomNavigationBarIndex(NavigatorConstants.ProfileTab);
      Provider.of<CustomAppBar>(context, listen: false).changeTitle("Profile");
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
