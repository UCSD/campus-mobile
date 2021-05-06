

import 'dart:core';

import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebView(String url, WebViewController controller) {
  controller?.loadUrl(url);
}

openLink(String url) async {
  try {
    launch(url, forceSafariVC: true);
  } catch (e) {
    // an error occurred, do nothing
  }
}

validateHeight(context, height) {
  double maxHeight = MediaQuery.of(context).size.height;
  if (height < cardContentMinHeight) {
    height = cardContentMinHeight;
  } else if (height > maxHeight) {
    height = maxHeight;
  }
  return height;
}
