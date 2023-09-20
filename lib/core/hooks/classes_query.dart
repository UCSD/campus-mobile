import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import 'package:intl/intl.dart';
import '../../app_networking.dart';
import '../models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import '../models/term.dart';

// TODO: Add error handling
// Fetches UNCourses using the provided access token
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
    // Fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=UN&term_code=' + term!,
        headers);
    /// Parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// Parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

// TODO: Add error handling
// Fetches GRCourses using the provided access token
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
    // Fetch data
    String _response = NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=GR&term_code=' + term!,
        headers) as String;
    /// Parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// Parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

// Fetches the current academic term
UseQueryResult<AcademicTermModel, dynamic> useFetchAcademicTerm() {
  final String academicTermEndpoint =
      'https://o17lydfach.execute-api.us-west-2.amazonaws.com/qa/v1/term/current';
  return useQuery(['academic_term'], () async {
    // Fetch data
    String _response = await NetworkHelper().fetchData(academicTermEndpoint);
    /// Parse data
    debugPrint("ClassScheduleModel QUERY HOOK: FETCHING DATA!");
    /// Parse data
    final data = academicTermModelFromJson(_response);
    return data;
  });
}

// Fetches enrolled class data from GR and UN courses
List<ClassData> fetchEnrolledClassData(ClassScheduleModel? grCoursesModel, ClassScheduleModel? unCoursesModel) {
  List<ClassData> enrolledClassesData = [];
  if (grCoursesModel != null) {
    for (ClassData classData in grCoursesModel.data!) {
      if (classData.enrollmentStatus == 'EN') {
        enrolledClassesData.add(classData);
      }
    }
  }
  if (unCoursesModel != null) {
    for (ClassData classData in unCoursesModel.data!) {
      if (classData.enrollmentStatus == 'EN') {
        enrolledClassesData.add(classData);
      }
    }
  }
  return enrolledClassesData;
}

// Fetches enrolled classes grouped by day
Map<String, List<SectionData>> fetchEnrolledClasses(List<ClassData> enrolledClassesData) {
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
  for (List<SectionData> listOfClasses in enrolledClasses!.values.toList()) {
    listOfClasses.sort((a, b) => _compare(a, b));
  }
  return enrolledClasses;
}

// Fetches midterm exams
Map<String, List<SectionData>> fetchMidterms(List<ClassData> enrolledClassesData) {
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
  for (List<SectionData> listOfMidterms in midterms!.values.toList()) {
    listOfMidterms.sort((a, b) => _compare(a, b));
    listOfMidterms.sort((a, b) => _compareMidterms(a, b));
  }
  return midterms;
}

// Fetches final exams
Map<String, List<SectionData>> fetchFinals(List<ClassData> enrolledClassesData) {
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
  for (List<SectionData> listOfFinals in finals!.values.toList()) {
    listOfFinals.sort((a, b) => _compare(a, b));
  }
  return finals;
}

// Helper function to build a grade evaluation string
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

// Retrieves a list of upcoming course sections for the given day or the next available day with classes.
List<SectionData> getUpcomingCourses(Map<String, List<SectionData>> enrolledClasses, String nextDayWithClass) {
  try {
    /// get weekday and return [List<SectionData>] associated with current weekday
    List<SectionData> listToReturn = [];
    String today = DateFormat('EEEE')
        .format(DateTime.now())
        .toString()
        .toUpperCase()
        .substring(0, 2);
    nextDayWithClass = DateFormat('EEEE').format(DateTime.now()).toString();

    /// if no classes are scheduled for today then find the next day with classes
    int daysToAdd = 1;

    while (enrolledClasses![today]!.isEmpty && daysToAdd <= 7) {
      today = DateFormat('EEEE')
          .format(DateTime.now().add(Duration(days: daysToAdd)))
          .toString()
          .toUpperCase()
          .substring(0, 2);
      nextDayWithClass = DateFormat('EEEE')
          .format(DateTime.now().add(Duration(days: daysToAdd)));
      daysToAdd += 1;
    }

    if (enrolledClasses![today]!.isNotEmpty) {
      listToReturn.addAll(enrolledClasses![today]!);
    } else {
      listToReturn.addAll([]);
    }
    return listToReturn;
  } catch (err) {
    print('classes provider err');
    print(err);
    return [];
  }
}


// Comparator that sorts SectionData objects by start time
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

// Comparator that sorts SectionData objects by date for midterms
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

// Helper function to extract the start time from a time string
DateTime _getStartTime(String time) {
  List<String> times = time.split("-");
  final format = DateFormat.Hm();
  return format.parse(times[0]);
}
