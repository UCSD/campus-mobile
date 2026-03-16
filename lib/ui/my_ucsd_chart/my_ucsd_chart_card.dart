import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const cardId = 'my_ucsd_chart';

class MyUCSDChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      cardId: cardId,
      active: context.select((CardsDataProvider p) => p.cardStates[cardId] ?? false),
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: null,
      child: () => buildCardContent(context),
      actionButtons: [
        ActionButton(
          buttonText: 'LOG IN TO MyUCSDChart',
          onPressed: () {
            analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'login'});
            try {
              const url = 'https://myucsdchart.ucsd.edu/UCSD/Authentication/Login';
              launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
            } catch (e) {
              // an error occurred, do nothing
            }
          },
        ),
      ],
    );
  }

  Widget buildCardContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/MyChartLogo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
            ),
          ),
          Flexible(
            child: Text(
              'Your secure online health connection.',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        ],
      ),
    );
  }
}
