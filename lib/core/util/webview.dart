import 'dart:core';
import 'dart:ui';

import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebViewWithTheme(
    BuildContext context, String url, WebViewController controller) {
  String themeURL = getThemeURL(context, url);
  controller?.loadUrl(themeURL);
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
  double newHeight = double.parse(
      await controller.evaluateJavascript("document.body.scrollHeight"));
  // double docBodyOffsetHeight = double.parse(
  //     await controller.evaluateJavascript("document.body.offsetHeight"));
  // double docElementClientHeight = double.parse(await controller
  //     .evaluateJavascript("document.documentElement.clientHeight"));
  // double docElementScrollHeight = double.parse(await controller
  //     .evaluateJavascript("document.documentElement.scrollHeight"));
  // double docElementOffsetHeight = double.parse(await controller
  //     .evaluateJavascript("document.documentElement.offsetHeight"));
  //
  // print(' ');
  // print('docBodyScrollHeight: ' + newHeight.toString());
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
