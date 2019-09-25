import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/ui/views/home.dart';
import 'package:campus_mobile/ui/views/map.dart';
import 'package:campus_mobile/ui/views/notifications.dart';
import 'package:campus_mobile/ui/views/profile.dart';

class Router {
    static Route<dynamic> generateRoute(RouteSettings settings) {
        switch (settings.name) {
            case RoutePaths.Home:
                return MaterialPageRoute(builder: (_) => Home());
            case RoutePaths.Map:
                return MaterialPageRoute(builder: (_) => Map(Colors.deepOrange));
            case RoutePaths.Notifications:
                return MaterialPageRoute(builder: (_) => Notifications(Colors.blue));
            case RoutePaths.Profile:
                return MaterialPageRoute(builder: (_) => Profile());
        }
    }
}
