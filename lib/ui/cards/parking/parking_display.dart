import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

final _url = "https://cqeg04fl07.execute-api.us-west-2.amazonaws.com/parking";

class ParkingDisplay extends StatelessWidget {
  const ParkingDisplay({
    Key key,
    @required this.model,
    // this.size
  }) : super(key: key);

  final ParkingModel model;
  // final Size size;

  @override
  Widget build(BuildContext context) {
    //TODO
    var lotQueryString = "lot=" + model.locationId + "&";
    const spotTypesQueryString =
        "spots=A,B,S&"; // Hardcoded for testing, will be passed in ;
    // const themeQueryString = "";
    // var dimentionsString = "width=" +
    //     size.width.toString() +
    //     "&height=" +
    //     size.height.toString() +
    //     "&";

    var url = _url + "?" + lotQueryString + spotTypesQueryString;
    WebViewController _controller;
    return WebView(
      initialUrl: url,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
    );
  }
}
