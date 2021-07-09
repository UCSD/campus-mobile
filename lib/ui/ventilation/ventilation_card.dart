import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String cardId = 'ventilation';

class VentilationCard extends StatelessWidget {
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
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildCardContent(BuildContext context) {
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

// class VentilationBuildings extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("HVAC: Manage Location"),
//       ),
//       body: ListView(
//         children: buildingsList(context),
//       ),
//     );
//   }
//
//   List<Widget> buildingsList(BuildContext context) {
//     List<Widget> list = [];
//     list.add(Container(
//       alignment: Alignment.topLeft,
//       child: Title(
//         color: Colors.black,
//         child: Container(
//           child: Text(
//             'Building:',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//           ),
//           margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
//         ),
//       ),
//     ));
//     list.add(Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade400,
//           ),
//         ),
//       ),
//       margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
//     ));
//
//     for (var i = 0; i < 5; i++) {
//       list.add(TextButton(
//           style: TextButton.styleFrom(
//             padding: const EdgeInsets.all(10),
//             primary: Colors.black,
//             textStyle: const TextStyle(fontSize: 20),
//           ),
//
//           // contains the text and right arrow of the textbutton
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // text
//               Container(
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text('Atkinson Hall'),
//                 ),
//                 margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
//               ),
//
//               // right arrow icon
//               Container(
//                 margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
//                 child: Icon(
//                   Icons.arrow_forward_ios,
//                 ),
//               ),
//             ],
//           ),
//           onPressed: () {
//             Navigator.pushNamed(context, RoutePaths.VentilationFloors);
//           }));
//       list.add(Container(
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: Colors.grey.shade400,
//             ),
//           ),
//         ),
//         margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//       ));
//     }
//
//     return list;
//   }
// }
