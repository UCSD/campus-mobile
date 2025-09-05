import 'package:flutter/material.dart';

class TabNavigatorKeys {
  static final homeTabKey = GlobalKey<NavigatorState>();
  static final mapTabKey = GlobalKey<NavigatorState>();
  static final notificationsTabKey = GlobalKey<NavigatorState>();
  static final profileTabKey = GlobalKey<NavigatorState>();

  static List<GlobalKey<NavigatorState>> get allKeys => [
    homeTabKey,
    mapTabKey,
    notificationsTabKey,
    profileTabKey,
  ];
}

