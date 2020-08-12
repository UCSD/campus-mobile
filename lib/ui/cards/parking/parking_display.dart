// import 'package:campus_mobile_experimental/core/models/parking_model.dart';
// import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// final _url = "https://cqeg04fl07.execute-api.us-west-2.amazonaws.com/parking";

// class ParkingDisplay extends StatelessWidget {
//   const ParkingDisplay({Key key, @required this.model, @required this.spotsState
//       // this.size
//       })
//       : super(key: key);

//   final ParkingModel model;
//   final Map<String, bool> spotsState;

//   @override
//   Widget build(BuildContext context) {
//     var spotTypesQueryString = '';


//     spotsState.forEach((key, value) {
//       if (value) spotTypesQueryString = '$spotTypesQueryString$key,';
//     });

//     if (spotTypesQueryString != '')
//       spotTypesQueryString = '&spots=$spotTypesQueryString';

//     //TODO
//     var lotQueryString = 'lot=${model.locationId}';

//     var url = '$_url?$lotQueryString$spotTypesQueryString';
//     print(url);
//     return new WebView(initialUrl: url);
//   }
// }
