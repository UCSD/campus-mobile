import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import 'package:intl/intl.dart';
import '../../app_networking.dart';
import '../models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import '../models/term.dart';

// TODO: add error handling
UseQueryResult<ClassScheduleModel, dynamic> useFetchUNCourses(String accessToken) {
  final Map<String, String> headers = {
    'Authorization':
    'Bearer $accessToken'
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

// TODO: add error handling
UseQueryResult<ClassScheduleModel, dynamic> useFetchGRCourses(String accessToken) {
  final Map<String, String> headers = {
    'Authorization':
    'Bearer $accessToken'
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

List<ClassData> useFetchEnrolledClassData(String accessToken) {
  final unCoursesModel = useFetchUNCourses(accessToken);
  final grCoursesModel = useFetchGRCourses(accessToken);
  var classScheduleModel;
  List<ClassData> enrolledClassesData = [];
  if (grCoursesModel.data != null) {
    classScheduleModel = grCoursesModel.data;
  }
  else {
    classScheduleModel = unCoursesModel.data;
  }
  for (ClassData classData in classScheduleModel!.data!) {
    if (classData.enrollmentStatus == 'EN') {
      enrolledClassesData.add(classData);
    }
  }
  return enrolledClassesData;
}

Map<String, List<SectionData>> useFetchEnrolledClasses(List<ClassData> enrolledClassesData) {
  Map<String, List<SectionData>> enrolledClasses = {
    'MO': [],
    'TU': [],
    'WE': [],
    'TH': [],
    'FR': [],
    'SA': [],
    'SU': [],
    'OTHER': [],
  };

  for (ClassData classData in enrolledClassesData) {
    for (SectionData sectionData in classData.sectionData!) {
      sectionData.subjectCode = classData.subjectCode;
      sectionData.courseCode = classData.courseCode;
      sectionData.courseTitle = classData.courseTitle;
      sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption);

      String? day = sectionData.days ?? 'OTHER';

      if (sectionData.specialMtgCode != 'FI' && sectionData.specialMtgCode != 'MI') {
        enrolledClasses[day]!.add(sectionData);
      }
    }
  }


  return enrolledClasses;
}

Map<String, List<SectionData>> useFetchMidterms(List<ClassData> enrolledClassesData) {
  Map<String, List<SectionData>> midterms = {
    'MI': [],
    'OTHER': [],
  };
  for (ClassData classData in enrolledClassesData) {
    for (SectionData sectionData in classData.sectionData!) {
      if (sectionData.specialMtgCode == 'MI') {
        midterms['MI']!.add(sectionData);
      }
    }
  }
  return midterms;
}

Map<String, List<SectionData>> useFetchFinals(List<ClassData> enrolledClassesData) {
  Map<String, List<SectionData>> finals = {
    'MO': [],
    'TU': [],
    'WE': [],
    'TH': [],
    'FR': [],
    'SA': [],
    'SU': [],
    'OTHER': [],
  };
  for (ClassData classData in enrolledClassesData) {
    for (SectionData sectionData in classData.sectionData!) {
      if (sectionData.specialMtgCode == 'FI') {
        String? day = sectionData.days ?? 'OTHER';
        finals[day]!.add(sectionData);
      }
    }
  }

  return finals;
}
// // TODO: research dependent queries for splitting this function
// /* fetches classes, finals, midterms */
// List<Map<String, List<SectionData>>> useFetchAll(String accessToken) {
//   final unCoursesModel = useFetchUNCourses(accessToken);
//   final grCoursesModel = useFetchGRCourses(accessToken);
//   var classScheduleModel;
//   if (grCoursesModel.data != null) {
//     classScheduleModel = grCoursesModel.data;
//   }
//   else {
//     classScheduleModel = unCoursesModel.data;
//   }
//
//   List<ClassData> enrolledClassesData = [];
//   Map<String, List<SectionData>> enrolledClasses = {
//     'MO': [],
//     'TU': [],
//     'WE': [],
//     'TH': [],
//     'FR': [],
//     'SA': [],
//     'SU': [],
//     'OTHER': [],
//   };
//
//   Map<String, List<SectionData>> finals = {
//     'MO': [],
//     'TU': [],
//     'WE': [],
//     'TH': [],
//     'FR': [],
//     'SA': [],
//     'SU': [],
//     'OTHER': [],
//   };
//   Map<String, List<SectionData>> midterms = {
//     'MI': [],
//     'OTHER': [],
//   };
//   List<Map<String, List<SectionData>>> finalList = [];
//
//
//   /// add only enrolled classes because api returns wait-listed and dropped
//   /// courses as well
//   for (ClassData classData in classScheduleModel!.data!) {
//     if (classData.enrollmentStatus == 'EN') {
//       enrolledClassesData.add(classData);
//     }
//   }
//
//   for (ClassData classData in enrolledClassesData) {
//     for (SectionData sectionData in classData.sectionData!) {
//       /// copy over info from [ClassData] object and put into [SectionData] object
//       sectionData.subjectCode = classData.subjectCode;
//       sectionData.courseCode = classData.courseCode;
//       sectionData.courseTitle = classData.courseTitle;
//       sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption);
//       String? day = 'OTHER';
//       if (sectionData.days != null) {
//         day = sectionData.days;
//       } else {
//         continue;
//       }
//
//       if (sectionData.specialMtgCode != 'FI' &&
//           sectionData.specialMtgCode != 'MI') {
//         enrolledClasses![day!]!.add(sectionData);
//       } else if (sectionData.specialMtgCode == 'FI') {
//         finals![day!]!.add(sectionData);
//       } else if (sectionData.specialMtgCode == 'MI') {
//         midterms!['MI']!.add(sectionData);
//       }
//     }
//   }
//
//   /// chronologically sort classes for each day
//   for (List<SectionData> listOfClasses in enrolledClasses!.values.toList()) {
//     listOfClasses.sort((a, b) => _compare(a, b));
//   }
//   for (List<SectionData> listOfFinals in finals!.values.toList()) {
//     listOfFinals.sort((a, b) => _compare(a, b));
//   }
//   for (List<SectionData> listOfMidterms in midterms!.values.toList()) {
//     listOfMidterms.sort((a, b) => _compare(a, b));
//     listOfMidterms.sort((a, b) => _compareMidterms(a, b));
//   }
//
//   finalList.add(enrolledClasses);
//   finalList.add(midterms);
//   finalList.add(finals);
//   return finalList;
// }

// Helper Functions

buildGradeEvaluation(String? gradeEvaluation) {
  switch (gradeEvaluation) {
    case 'L':
      {
        return 'Letter Grade';
      }
    case 'P':
      {
        return 'Pass/No Pass';
      }
    case 'S':
      {
        return 'Sat/Unsat';
      }
    default:
      {
        return 'Other';
      }
  }
}

int _compareMidterms(SectionData a, SectionData b) {
  DateTime dateTimeA = DateFormat('yyyy-M-dd').parse(a.date!);
  DateTime dateTimeB = DateFormat('yyyy-M-dd').parse(b.date!);

  if (dateTimeA.compareTo(dateTimeB) == 0) {
    return 0;
  }
  if (dateTimeA.compareTo(dateTimeB) < 0) {
    return -1;
  }
  return 1;
}

/// comparator that sorts according to start time of class
int _compare(SectionData a, SectionData b) {
  if (a.time == null || b.time == null) {
    return 0;
  }
  DateTime aStartTime = _getStartTime(a.time!);
  DateTime bStartTime = _getStartTime(b.time!);

  if (aStartTime == bStartTime) {
    return 0;
  }
  if (aStartTime.isBefore(bStartTime)) {
    return -1;
  }
  return 1;
}

DateTime _getStartTime(String time) {
  List<String> times = time.split("-");
  final format = DateFormat.Hm();
  return format.parse(times[0]);
}




