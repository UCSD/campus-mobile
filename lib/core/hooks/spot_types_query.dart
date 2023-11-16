import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';

UseQueryResult<SpotTypeModel, dynamic> useFetchSpotTypes() {
  return useQuery(['spotType'], () async {
    /// fetch data
    String _response = await NetworkHelper().fetchData(
        "https://mobile.ucsd.edu/replatform/v1/qa/integrations/parking/v1.2/spot_types.json");
    debugPrint("SpotTypeModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = spotTypeModelFromJson(_response);
    return data;
  });
}

// void toggleSpotSelection(String? spotKey, int spotsSelected) {
//   selectedSpots = spotsSelected;
//   if (selectedSpots < MAX_SELECTED_SPOTS) {
//     _selectedSpotTypesState![spotKey] = !_selectedSpotTypesState![spotKey]!;
//     _selectedSpotTypesState![spotKey]! ? selectedSpots++ : selectedSpots--;
//   } else {
//     //prevent select
//     if (_selectedSpotTypesState![spotKey]!) {
//       selectedSpots--;
//       _selectedSpotTypesState![spotKey] = !_selectedSpotTypesState![spotKey]!;
//     }
//   }
//   _userDataProvider.userProfileModel!.disabledParkingSpots =
//       _selectedSpotTypesState;
//   _userDataProvider.postUserProfile(_userDataProvider.userProfileModel);
//   notifyListeners();
// }
