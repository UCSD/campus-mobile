import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String cardId = 'MyUCSDChart';

class MyChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildCardContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        handleTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/MyChartLogo.png',
              fit: BoxFit.contain,
              height: 56,
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
          ),
          Flexible(
            child: Text(
              'Your secure online health connection.',
              textAlign: TextAlign.left,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'Log in to MyUCSDChart',
      ),
      onPressed: () {
        handleTap();
      },
    ));
    return actionButtons;
  }

  void handleTap() {
    String myChartUrl =
        'https://mystudentchart.ucsd.edu/shs/Authentication/Saml/Login?IdP=UCSD%20STUDENT%20AD%20LOGIN';
    openLink(myChartUrl);
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      // can't launch url, there is some error
    }
  }
}
