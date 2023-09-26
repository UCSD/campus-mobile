import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/notices.dart';

UseQueryResult<List<NoticesModel>, dynamic> useFetchNotices() {
  return useQuery(['notices'], () async {
    /// fetch data
    String _response = await NetworkHelper().fetchData(
        'https://mobile.ucsd.edu/replatform/v1/qa/notices-v2.json');
    debugPrint("NoticesModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = noticesModelFromJson(_response);
    return data;
  });
}