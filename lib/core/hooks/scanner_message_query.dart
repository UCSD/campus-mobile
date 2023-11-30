
import 'package:campus_mobile_experimental/core/models/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';
import '../../app_networking.dart';


UseQueryResult<ScannerMessageModel, dynamic> useFetchScannerMessage(String accessToken)
{
  debugPrint("Entering Hook -- " + accessToken);
  const String myStudentProfileApiUrl =
      'https://api-qa.ucsd.edu:8243/scandata/2.0.0/scanData/myrecentscan/';

  return useQuery(['ScannerMessage'], () async {
    /// fetch data
    final headers =  {"Authorization": 'Bearer $accessToken'};

    String _response = await NetworkHelper().authorizedFetch(myStudentProfileApiUrl, headers);
    debugPrint(_response);
    debugPrint("ScannerMessage QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = scannerMessageModelFromJson(_response );
    return data;
  });
}

