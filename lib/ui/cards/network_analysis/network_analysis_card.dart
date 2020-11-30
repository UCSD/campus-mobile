//import 'dart:io';
// import 'dart:js';


import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/student_id_barcode_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';


class NetworkAnalysisCard extends StatefulWidget {
  @override
  _NetworkAnalysisCardState createState() => _NetworkAnalysisCardState();
}

class _NetworkAnalysisCardState extends State<NetworkAnalysisCard> {
  String cardId = "network_analysis";

  @override
  Widget build(BuildContext context) {
    print("Tried creating network card.");
    //ScalingUtility().getCurrentMeasurements(context);

    return CardContainer(
      active: Provider
          .of<CardsDataProvider>(context)
          .cardStates[cardId],
      hide: () =>
          Provider.of<CardsDataProvider>(context, listen: false)
              .toggleCard(cardId),
      reload: () =>
          Provider.of<StudentIdDataProvider>(context, listen: false)
              .fetchData(),
      isLoading: Provider
          .of<StudentIdDataProvider>(context)
          .isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider
          .of<StudentIdDataProvider>(context)
          .error,
      child: () => buildCardContent(context),
    );
  }

  Widget buildTitle() {
    return Text(
      "Network Analysis Card",
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: ScalingUtility.horizontalSafeBlock * 2,
      ),
    );
  }

  Widget buildCardContent(BuildContext context) {
// WifiInfo wifiConnection;
// WifiConnection.wifiInfo.then((value){
//   wifiConnection = value;
// });
      return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: (Column(children: <Widget>[
           //  FutureBuilder(
           //    future: WifiConnection.wifiInfo,
           //    builder: (context, snapshot){
           //      if(snapshot.connectionState == ConnectionState.done){
           //        return Column(
           //          children: [
           //            Text(wifiConnection.bssId),
           //            Text(wifiConnection.ssid),
           //            Text(wifiConnection.ipAddress),
           //            Text(wifiConnection.macAddress),
           //          ],
           //        );
           //      }
           //      return CircularProgressIndicator();
           //    },
           // ),
              Text("Hello")
          ])
          ));

  }
}




//Image Scaling
class ScalingUtility {
  MediaQueryData _queryData;
  static double horizontalSafeBlock;
  static double verticalSafeBlock;

  void getCurrentMeasurements(BuildContext context) {
    /// Find screen size
    _queryData = MediaQuery.of(context);

    /// Calculate blocks accounting for notches and home bar
    horizontalSafeBlock = (_queryData.size.width -
        (_queryData.padding.left + _queryData.padding.right)) /
        100;
    verticalSafeBlock = (_queryData.size.height -
        (_queryData.padding.top + _queryData.padding.bottom)) /
        100;
  }
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
