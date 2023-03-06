import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/employee_id.dart';

UseQueryResult<EmployeeIdModel, dynamic> useFetchEmployeeIdModel(String accessToken)
{
  return useQuery(['employee_id'], () async {
    // fetch data
    // TODO: go ahead and fetch the data from the endpoint (see employee id service file)
    // TODO: convert data from JSON map to Model class instance
    String _response = await NetworkHelper().authorizedFetch(
        'https://api-qa.ucsd.edu:8243/staff/my/v1/profile', {
        "Authorization": 'Bearer $accessToken'
    });
    debugPrint("EmployeeIdModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = employeeIdModelFromJson(_response);
    return data;
  });
}