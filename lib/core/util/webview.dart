import 'dart:core';

import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebView(String url, WebViewController controller) {
  controller?.loadUrl(url);
}

Future<double> getNewContentHeight(
    WebViewController controller, double oldHeight) async {
  double docBodyScrollHeight = double.parse(
      await controller.evaluateJavascript("document.body.scrollHeight"));
  double docBodyOffsetHeight = double.parse(
      await controller.evaluateJavascript("document.body.offsetHeight"));
  double docElementClientHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.clientHeight"));
  double docElementScrollHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.scrollHeight"));
  double docElementOffsetHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.offsetHeight"));

  // print('docBodyScrollHeight: ' + docBodyScrollHeight.toString());
  // print('docBodyOffsetHeight: ' + docBodyOffsetHeight.toString());
  // print('docElementClientHeight: ' + docElementClientHeight.toString());
  // print('docElementScrollHeight: ' + docElementScrollHeight.toString());
  // print('docElementOffsetHeight: ' + docElementOffsetHeight.toString());

  // List<double> documentHeight = [];
  // documentHeight.addAll([
  //   docBodyScrollHeight,
  //   docBodyOffsetHeight,
  //   docElementClientHeight,
  //   docElementScrollHeight,
  //   docElementOffsetHeight,
  // ]);

  // double newHeight = documentHeight.reduce(max);

  double newHeight = docBodyOffsetHeight;

  // print('oldHeight: ' + oldHeight.toString());
  // print('newHeight: ' + newHeight.toString());

  if (oldHeight != newHeight) {
    if (newHeight < cardContentMinHeight) {
      newHeight = cardContentMinHeight;
    } else if (newHeight > cardContentMaxHeight) {
      newHeight = cardContentMaxHeight;
    }
  }
  return newHeight;
}

openLink(String url) async {
  try {
    launch(url, forceSafariVC: true);
  } catch (e) {
    // an error occurred, do nothing
  }
}
