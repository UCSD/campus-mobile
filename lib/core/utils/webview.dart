import 'dart:core';

import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebView(String url, WebViewController controller) {
  controller?.loadUrl(url);
}

Future<double> getNewContentHeight(
    WebViewController controller, double oldHeight) async {
  double newHeight = double.parse(
      await controller.evaluateJavascript("document.body.offsetHeight"));
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
