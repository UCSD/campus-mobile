import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/student_id_barcode.dart';
import '../models/student_id_photo.dart';
import '../models/student_id_profile.dart';
import '../models/student_id_name.dart';

UseQueryResult<StudentIdBarcodeModel, dynamic> useFetchStudentIdBarcodeModel(String accessToken)
{
  const String myStudentContactApiUrl =
      'https://api-qa.ucsd.edu:8243/student/my/student_contact_info/v1';

  return useQuery(['StudentIdBarcode'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myStudentContactApiUrl + '/barcode', {
      "Authorization": 'Bearer $accessToken'
    });

    debugPrint("StudentIdBarcodeModel QUERY HOOK: FETCHING DATA!");

    /// parse data
   final data = studentIdBarcodeModelFromJson(_response);
    return data;
  });
}


UseQueryResult<StudentIdProfileModel, dynamic> useFetchStudentIdProfileModel(String accessToken)
{
  const String myStudentProfileApiUrl =
      'https://api-qa.ucsd.edu:8243/student/my/v1';

  return useQuery(['StudentIdProfile'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myStudentProfileApiUrl + '/profile', {
      "Authorization": 'Bearer $accessToken'
    });

    debugPrint("StudentIdProfileModel QUERY HOOK: FETCHING DATA!");

    /// parse data
   final data = studentIdProfileModelFromJson(_response);
    return data;
  });
}

UseQueryResult<StudentIdPhotoModel, dynamic> useFetchStudentIdPhotoModel(String accessToken)
{
  const String myStudentContactApiUrl =
      'https://api-qa.ucsd.edu:8243/student/my/student_contact_info/v1';

  return useQuery(['StudentIdPhoto'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myStudentContactApiUrl + '/photo', {
      "Authorization": 'Bearer $accessToken'
    });

    debugPrint("StudentIdPhotoModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = studentIdPhotoModelFromJson(_response);
    return data;
  });
}

UseQueryResult<StudentIdNameModel,dynamic> useFetchStudentIdNameModel(String accessToken)
{
  const String myStudentContactApiUrl =
      'https://api-qa.ucsd.edu:8243/student/my/student_contact_info/v1';

  return useQuery(['StudentIdName'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myStudentContactApiUrl + '/display_name', {
      "Authorization": 'Bearer $accessToken'
    });

    debugPrint("StudentIdNameModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = studentIdNameModelFromJson(_response);
    return data;
  });
}