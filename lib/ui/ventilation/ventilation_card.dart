import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String cardId = 'ventilation';

class VentilationCard extends StatefulWidget {
  @override
  _VentilationCardState createState() => _VentilationCardState();
}

class _VentilationCardState extends State<VentilationCard> {
  VentilationDataProvider _ventilationDataProvider = VentilationDataProvider();

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _ventilationDataProvider = Provider.of<VentilationDataProvider>(context);
  // }

  @override
  Widget build(BuildContext context) {
    print("Context in ventilation card: $context");

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(
          context, _ventilationDataProvider.ventilationLocationModels),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildCardContent(
      BuildContext context, List<VentilationLocationsModel> locations) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                'Bonner Hall',
                style: TextStyle(color: Colors.grey[600], fontSize: 20),
                textAlign: TextAlign.left,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            ),
            Container(
              child: Text(
                'Room 301',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey[600], fontSize: 20),
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              child: Text(
                '3rd floor',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
                textAlign: TextAlign.left,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Currently 74°',
                        style: TextStyle(color: Colors.black, fontSize: 36),
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.window),
                    Container(
                      child: Text(
                        'Windows are closed',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.air),
                    Container(
                      child: Text(
                        'HVAC is active',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        primary: Theme.of(context).buttonColor,
      ),
      child: Text(
        'Manage Locations',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.VentilationBuildings);
      },
    ));
    return actionButtons;
  }

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }
}
