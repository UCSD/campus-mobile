import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

final _url = "https://cqeg04fl07.execute-api.us-west-2.amazonaws.com/parking";

class ParkingDisplay extends StatelessWidget {
  const ParkingDisplay({
    Key key,
    @required this.model,
  }) : super(key: key);

  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    //TODO
    const spotTypesQueryString =
        "spots=A,B,S"; // Hardcoded for testing, will be passed in ;
    var lotQueryString = "lot=" + model.locationId;
    const themeQueryString = "";

    var url = _url +
        "?" +
        lotQueryString +
        "&" +
        spotTypesQueryString +
        "&" +
        themeQueryString;
    print("\n\n\n"+url);
    return WebView(
        javascriptMode: JavascriptMode.unrestricted, initialUrl: url);
  }
}