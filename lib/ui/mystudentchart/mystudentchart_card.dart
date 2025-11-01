import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const cardId = 'MyStudentChart';

class MyStudentChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId]!,
      errorText: null,
      child: () => buildCardContent(context),
      actionButtons: [
        ActionButton(
          buttonText: 'LOG IN TO MyStudentChart',
          onPressed: () {
            try {
              launch(
                'https://mystudentchart.ucsd.edu/SHS/Authentication/Saml/Login?idp=UCSD_STUDENT_AD_LOGIN',
                forceSafariVC: true,
              );
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
            child: Image.asset('assets/images/MyChartLogo.png', fit: BoxFit.contain, height: 32),
            padding: EdgeInsets.only(left: 16, right: 8),
          ),
          Flexible(
            child: Text(
              'Your secure online health connection.',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
