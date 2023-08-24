import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:fquery/fquery.dart';

// STAGE 1 - LOADING AND INIT
UseQueryResult<List<ParkingModel>, dynamic> useFetchParkingModels(String pid)
{
  return useQuery(['parking'], () async {
    print (pid);
    throw UnimplementedError("PARKING MODEL FQUERY HOOK NOT IMPLEMENTED");
  });
}