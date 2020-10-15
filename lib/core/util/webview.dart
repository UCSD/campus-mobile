import 'dart:core';
import 'dart:ui';

import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebViewWithTheme(
    BuildContext context, String url, WebViewController controller) {
  String themeURL = getThemeURL(context, url);
  controller?.loadUrl(themeURL);
}

void reloadWebView(String url, WebViewController controller) {
  print('Reload webview (disabled): ' + url);
  controller?.loadUrl(url);
}

String getThemeURL(BuildContext context, String url) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return url.contains('?') ? url += '&theme=dark' : url += '?theme=dark';
  } else {
    return url.contains('?') ? url += '&theme=light' : url += '?theme=light';
  }
}

Future<double> getNewContentHeight(
    WebViewController controller, double oldHeight) async {
  double docBodyScrollHeight = double.parse(
      await controller.evaluateJavascript("document.body.scrollHeight"));

  double newHeight = double.parse(
      await controller.evaluateJavascript("document.body.offsetHeight"));

  double docElementClientHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.clientHeight"));

  double docElementScrollHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.scrollHeight"));

  double docElementOffsetHeight = double.parse(await controller
      .evaluateJavascript("document.documentElement.offsetHeight"));

  print(' ');
  print('docBodyScrollHeight: ' + docBodyScrollHeight.toString());
  print('docBodyOffsetHeight: ' + newHeight.toString());
  print('docElementClientHeight: ' + docElementClientHeight.toString());
  print('docElementScrollHeight: ' + docElementScrollHeight.toString());
  print('docElementOffsetHeight: ' + docElementOffsetHeight.toString());

  // List<double> documentHeight = [];
  // documentHeight.addAll([
  //   docBodyScrollHeight,
  //   docBodyOffsetHeight,
  //   docElementClientHeight,
  //   docElementScrollHeight,
  //   docElementOffsetHeight,
  // ]);

  // double newHeight = documentHeight.reduce(max);

  // print('oldHeight: ' +
  //     oldHeight.toString() +
  //     ', newHeight: ' +
  //     newHeight.toString());

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
