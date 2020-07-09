import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

final _url = "https://reactauthtest-e9a4e.web.app/";

class ParkingDisplay extends StatelessWidget {
  const ParkingDisplay({
    Key key,
    @required this.model,
  }) : super(key: key);

  final ParkingModel model;

  @override
  Widget build(BuildContext context) {
    return  WebView(javascriptMode: JavascriptMode.unrestricted, initialUrl: _url);}
    // return Column(
    //   children: [
    //     buildLocationTitle(),
    //     buildLocationContext(),
    //     buildSpotsAvailableText(),
    //     buildAllParkingAvailability(),
    //   ],
    // );
  }

//   Widget buildAllParkingAvailability() {
//     List<Widget> listOfCircularParkingInfo = List<Widget>();
//     listOfCircularParkingInfo
//         .add(buildCircularParkingInfo(model.availability.a));
//     listOfCircularParkingInfo
//         .add(buildCircularParkingInfo(model.availability.b));
//     listOfCircularParkingInfo
//         .add(buildCircularParkingInfo(model.availability.s));
//     listOfCircularParkingInfo
//         .add(buildCircularParkingInfo(model.availability.accessible));
//     listOfCircularParkingInfo
//         .add(buildCircularParkingInfo(model.availability.v));
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: listOfCircularParkingInfo,
//     );
//   }

//   Widget buildCircularParkingInfo(SpotType spot) {
//     return spot != null
//         ? Column(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       value: (spot.open / spot.total),
//                       valueColor: AlwaysStoppedAnimation<Color>(ColorPrimary),
//                     ),
//                     Center(
//                       child: Text(
//                           ((spot.open / spot.total) * 100).round().toString() +
//                               "%"),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: CircleAvatar(
//                   backgroundColor: spot.color,
//                   child: spot.type,
//                 ),
//               )
//             ],
//           )
//         : Container();
//   }

//   Widget buildLocationContext() {
//     return Center(
//       child: Text(model.locationContext),
//     );
//   }

//   Widget buildLocationTitle() {
//     return Text(model.locationName);
//   }

//   Widget buildSpotsAvailableText() {
//     return Center(
//       child: Text("~" +
//           model.availability.totalSpotsOpen.toString() +
//           " Spots Available"),
//     );
//   }
// }
