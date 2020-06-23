import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ParkingWebViewContainer extends StatefulWidget {
  final url;
  ParkingWebViewContainer(this.url);
  @override
  createState() => _ParkingWebViewContainerState(this.url);
}

class _ParkingWebViewContainerState extends State<ParkingWebViewContainer> {
  var _url;
  final _key = UniqueKey();
  _ParkingWebViewContainerState(this._url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: _url))
          ],
        ));
  }
}
