import 'package:intl/intl.dart';

class Credit {
  final String feature;
  final String ideaOwner;
  final String devName;
  final DateTime date;

  const Credit({required this.feature, required this.ideaOwner, required this.devName, required this.date});

  String get formattedDate => DateFormat.yMMMMd('en_US').format(date);

  String get description => '$feature was suggested by $ideaOwner and implemented by $devName on $formattedDate.';
}

Credit credit({required String feature, required String ideaOwner, required String devName, required DateTime date}) =>
    Credit(feature: feature, ideaOwner: ideaOwner, devName: devName, date: date);
