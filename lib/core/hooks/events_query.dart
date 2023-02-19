import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/events.dart';

UseQueryResult<List<EventModel>, dynamic> useFetchEventsModels() {
  return useQuery(['events'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        "'https://hmczfnmm84.execute-api.us-west-2.amazonaws.com/qa/v2/events/student';",
        {
          "Authorization":
              "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
        });

    debugPrint("Event Model QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = eventModelFromJson(_response);
    return data;
  });
}
