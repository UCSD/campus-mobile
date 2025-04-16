import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BuildInfo extends StatefulWidget {
  @override
  _BuildInfoState createState() => _BuildInfoState();
}

class _BuildInfoState extends State<BuildInfo> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    packageName: 'Unknown',
  );

  /// STATES
  final buildEnv = dotenv.get('BUILD_ENV');

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              color: Theme.of(context).brightness == Brightness.dark
                  ? listTileDividerColorDark
                  : listTileDividerColorLight, // Set the color of the divider
              thickness: 0.5, // Set the thickness of the divider
            ),
            Text(
              _packageInfo.appName +
                  ' ' +
                  _packageInfo.version +
                  ' (' +
                  _packageInfo.buildNumber +
                  ')' +
                  (buildEnv == 'PROD' ? '' : buildEnv),
              style: Theme.of(context).brightness == Brightness.dark
                  ? descriptiveTextSmallDark
                  : descriptiveTextSmallLight,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } catch (err) {
      print(err);
      return Container();
    }
  }
}
