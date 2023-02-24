import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:fquery/fquery.dart';

UseQueryResult<List<ParkingModel>, dynamic> useFetchParkingModels()
{
  return useQuery(['parking'], () async {
    throw UnimplementedError("PARKING MODEL FQUERY HOOK NOT IMPLEMENTED");
  });
}