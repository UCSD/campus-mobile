//This will be the style guide used for this project
//https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo
import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_mobile/provider.dart';
import 'package:campus_mobile/ui/router.dart';
import 'package:campus_mobile/ui/theme/app_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'UC San Diego',
        theme: ThemeData(
          primarySwatch: ColorPrimary,
        ),
        initialRoute: RoutePaths.Home,
        onGenerateRoute: Router.generateRoute,
      ),
    );
  }
}
