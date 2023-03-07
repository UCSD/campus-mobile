import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/events.dart';
import '../models/news.dart';

UseQueryResult<NewsModel, dynamic> useFetchNewsModels() {
  return useQuery(['news'], () async {
    /// fetch data
    final Map<String, String> headers = {
        "accept": "application/json",
      "Authorization":
      "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
      };
    String _response = await NetworkHelper().authorizedFetch(
        "https://api-qa.ucsd.edu:8243/campusnews/1.0.0/ucsdnewsaggregator",
        headers);

    debugPrint("News Model QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = newsModelFromJson(_response);
    return data;
  });
}
