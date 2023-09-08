import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import '../models/term.dart';


UseQueryResult<ClassScheduleModel, dynamic> useFetchUNCourses() {
  final Map<String, String> headers = {
    'Authorization':
    'Bearer ${UserDataProvider().authenticationModel?.accessToken}'
  };
  final termModel = useFetchAcademicTerm();
  String? term = termModel.data?.termCode;
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';
  return useQuery(['un_courses'], () async {
    // fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=UN&term_code=' + term!,
        headers);
    /// parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

UseQueryResult<ClassScheduleModel, dynamic> useFetchGRCourses() {
  final Map<String, String> headers = {
    'Authorization':
    'Bearer ${UserDataProvider().authenticationModel?.accessToken}'
  };
  final termModel = useFetchAcademicTerm();
  String? term = termModel.data?.termCode;
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';
  return useQuery(['gr_courses'], () async {
    // fetch data
    String _response = NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=GR&term_code=' + term!,
        headers) as String;
    /// parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

UseQueryResult<AcademicTermModel, dynamic> useFetchAcademicTerm() {
  final String academicTermEndpoint =
      'https://o17lydfach.execute-api.us-west-2.amazonaws.com/qa/v1/term/current';
  return useQuery(['academic_term'], () async {
    // fetch data
    String _response = await NetworkHelper().fetchData(academicTermEndpoint);
    /// parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// parse data
    final data = academicTermModelFromJson(_response);
    return data;
  });
}

/* fetches classes, finals, midterms */
UseQueryResult<List<Map<String, List<SectionData>>>, dynamic> useFetchAll() {
  final unCoursesModel = useFetchUNCourses();
  final grCoursesModel = useFetchGRCourses();
  var classScheduleModel;
  if (grCoursesModel.data != null) {
    classScheduleModel = grCoursesModel.data;
  }
  else {
    classScheduleModel = unCoursesModel.data;
  }

  List<ClassData> enrolledCourses = [];

  /// add only enrolled classes because api returns wait-listed and dropped
  /// courses as well
  for (ClassData classData in classScheduleModel!.data!) {
    if (classData.enrollmentStatus == 'EN') {
      enrolledCourses.add(classData);
    }
  }

  for (ClassData classData in enrolledCourses) {
    for (SectionData sectionData in classData.sectionData!) {
      /// copy over info from [ClassData] object and put into [SectionData] object
      sectionData.subjectCode = classData.subjectCode;
      sectionData.courseCode = classData.courseCode;
      sectionData.courseTitle = classData.courseTitle;
      sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption);
      String? day = 'OTHER';
      if (sectionData.days != null) {
        day = sectionData.days;
      } else {
        continue;
      }

      if (sectionData.specialMtgCode != 'FI' &&
          sectionData.specialMtgCode != 'MI') {
        _enrolledClasses![day!]!.add(sectionData);
      } else if (sectionData.specialMtgCode == 'FI') {
        _finals![day!]!.add(sectionData);
      } else if (sectionData.specialMtgCode == 'MI') {
        _midterms!['MI']!.add(sectionData);
      }
    }
  }
}




