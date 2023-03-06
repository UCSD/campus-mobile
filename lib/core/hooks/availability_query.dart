import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/availability.dart';

UseQueryResult<List<AvailabilityModel>, dynamic> useFetchAvailabilityModels()
{
  return useQuery(['availability'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        "https://api-qa.ucsd.edu:8243/campusbusyness/v1/busyness", {
      "Authorization": "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    });
    debugPrint("AvailabilityModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = availabilityStatusFromJson(_response).data!;
    return data;
  });
}
