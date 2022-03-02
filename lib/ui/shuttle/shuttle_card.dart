import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

const String cardId = 'shuttle';

class ShuttleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  Widget buildCardContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8, right: 64, bottom: 8, left: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'The shuttle tracking card is offline due to an update.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          SizedBox(height: 16),
          OutlinedButton(
              onPressed: () {
                openLink('https://tritontransit.ridesystems.net/routes');
              },
              child: Text('View live map',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  )))
        ],
      ),
    );
  }
}
