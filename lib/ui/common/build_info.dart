import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class DebugBuildInfo extends StatefulWidget {
  @override
  _DebugBuildInfoState createState() => _DebugBuildInfoState();
}

class _DebugBuildInfoState extends State<DebugBuildInfo> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Foundation.kDebugMode
        ? Expanded(
            child: SingleChildScrollView(
              child: Theme(
                data: ThemeData(
                  dividerColor: lightAccentColor,
                ),
                child: DataTable(
                    horizontalMargin: 0.0,
                    columnSpacing: 10.0,
                    headingRowHeight: 30.0,
                    dataRowHeight: 30.0,
                    columns: [
                      DataColumn(
                          label: Text(
                        'Debug Build Info',
                        style: debugHeader,
                      )),
                      DataColumn(
                          label: Text(
                        '',
                        style: debugHeader,
                      )),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('App Name', style: debugRow)),
                        DataCell(Text(
                          _packageInfo.appName ?? 'N/A',
                          style: debugRow,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'App ID',
                          style: debugRow,
                        )),
                        DataCell(Text(
                          _packageInfo.packageName ?? 'N/A',
                          style: debugRow,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Version',
                          style: debugRow,
                        )),
                        DataCell(Text(
                          _packageInfo.version ?? 'N/A',
                          style: debugRow,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Build',
                          style: debugRow,
                        )),
                        DataCell(Text(
                          _packageInfo.buildNumber ?? 'N/A',
                          style: debugRow,
                        )),
                      ]),
                      // ##PRE_BUILD_DEBUG_SUPPLEMENTAL## (Do Not Remove)
                    ]),
              ),
            ),
            flex: 1,
          )
        : Container();
  }
}
