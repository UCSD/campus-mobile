import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebViewWithTheme(BuildContext context, String url, WebViewController controller) {
  var darkModeUrl = getDarkModeUrl(context, url);
  if(controller != null) {
    controller?.loadUrl(darkModeUrl);
  }
}

String getDarkModeUrl(BuildContext context, String url) {
  if (Theme.of(context).brightness == Brightness.dark) {
    url += "&darkmode=true";
  } else {
    url += "&darkmode=false";
  }

  return url;
}