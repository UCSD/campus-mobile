import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/scanner.dart';
import 'package:campus_mobile_experimental/core/providers/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

const cardId = 'NativeScanner';

class NativeScannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: context.watch<CardsDataProvider>().cardStates[cardId],
      hide: () => context.read<CardsDataProvider>().toggleCard(cardId),
      reload: () =>
          Provider.of<ScannerMessageDataProvider>(context, listen: false)
              .fetchData(),
      isLoading: Provider.of<ScannerMessageDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId]!,
      errorText: null,
      child: () => buildCardContent(context),
      actionButtons: [buildActionButton(context)],
    );
  }

  Widget buildCardContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/images/QRScanIcon.png',
            fit: BoxFit.contain,
            height: 24,
          ),
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 4,
          ),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getCardContentText(context),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
              ),
              getMessageWidget(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildActionButton(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll<Color>(const Color(0xFFFFCD00)),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        alignment: Alignment.bottomCenter,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Text(
          getActionButtonText(context),
          style: buttonTextStyle,
        ),
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
              .scannerMessageModel
              .collectionTime;
      if (myRecentScanTime == "")
        myRecentScanTime = ScannerError.noRecentScan.msg;
      return (Padding(
        padding: EdgeInsets.only(top: 8.0, right: 8.0),
        child: Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 18),
            children: [
              TextSpan(
                text: "Last test kit scan: ",
              ),
              TextSpan(
                text: DateFormat('MMMM d, yyyy').format(
                  DateFormat('yyyy-MM-dd hh:mm a').parse(
                    Provider.of<ScannerMessageDataProvider>(context,
                                listen: false)
                            .scannerMessageModel
                            .collectionTime ??
                        '',
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    } else {
      return Container(width: 0, height: 0);
    }
  }

  void getActionButtonNavigateRoute(BuildContext context) {
    if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
      Provider.of<ScannerDataProvider>(context, listen: false)
          .resetDefaultStates();
      Navigator.pushNamed(context, RoutePaths.ScanditScanner);
    } else {
      Provider.of<BottomNavigationBarProvider>(context, listen: false)
          .currentIndex = NavigatorConstants.ProfileTab;
      Provider.of<CustomAppBar>(context, listen: false).changeTitle("Profile");
    }
  }
}
