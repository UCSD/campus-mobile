import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ClassScheduleModel data =
        Provider.of<ClassScheduleDataProvider>(context).classScheduleModel;
    return Container();
  }
}
