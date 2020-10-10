import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void reloadWebViewWithTheme(
    BuildContext context, String url, WebViewController controller) {
  controller?.loadUrl(getThemeURL(context, url));
}

String getThemeURL(BuildContext context, String url) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return url.contains('?') ? url += '&theme=dark' : url += '?theme=dark';
  } else {
    return url.contains('?') ? url += '&theme=light' : url += '?theme=light';
  }
}
