import 'package:fquery/fquery.dart';

import '../models/employee_id.dart';

UseQueryResult<EmployeeIdModel, dynamic> useFetchEmployeeIdModel()
{
  return useQuery(['employee_id'], () async {
    // fetch data
    // TODO: go ahead and fetch the data from the endpoint (see employee id service file)
    // TODO: convert data from JSON map to Model class instance

    throw UnimplementedError("EMPLOYEE ID HOOK NOT DONE YET!");
  });
}