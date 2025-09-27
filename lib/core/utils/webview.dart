import 'dart:core';

import 'package:campus_mobile/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebView(String url, WebViewController controller) => controller.loadRequest(Uri.parse(url));

void openLink(String url) async {
  try {
    launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  } catch (e) {
    // an error occurred, do nothing
  }
}

double validateHeight(context, height) {
  double maxHeight = MediaQuery.of(context).size.height * 0.6; // Limit to 60% of screen height
  if (height == null || height < cardContentMinHeight) {
    height = cardContentMinHeight;
  } else if (height > maxHeight) {
    height = maxHeight;
  }
  return height;
}
