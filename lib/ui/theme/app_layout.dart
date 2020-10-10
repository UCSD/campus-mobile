import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Card Layout
const cardMargin = 6.0;
const cardPaddingInner = 8.0;
const cardMinHeight = 60.0;
const listTileInnerPadding = 8.0;

//Card Heights
const cardContentMinHeight = 40.0;
const cardContentMaxHeight = 568.0;

Future<double> getNewContentHeight(
    WebViewController controller, double oldHeight) async {
  double newHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.offsetHeight"));
  if (oldHeight != newHeight) {
    if (newHeight < cardContentMinHeight) {
      newHeight = cardContentMinHeight;
    } else if (newHeight > cardContentMaxHeight) {
      newHeight = cardContentMaxHeight;
    }
  }
  return newHeight;
}
