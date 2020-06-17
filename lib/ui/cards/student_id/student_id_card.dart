import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';

import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/weather_data_provider.dart';

const String WEATHER_ICON_BASE_URL =
    'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/';

class StudentIdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      active: Provider.of<UserDataProvider>(context).cardStates['student_id'],
      hide: () => Provider.of<UserDataProvider>(context, listen: false)
          .toggleCard('student_id'),
      reload: () => Provider.of<StudentIdDataProvider>(context, listen: false)
          .fetchWeather(),
      isLoading: Provider.of<StudentIdDataProvider>(context).isLoading,
      title: buildTitle(),
      errorText: Provider.of<StudentIdDataProvider>(context).error,
      child: () => buildCardContent(
          Provider.of<StudentIdDataProvider>(context).studentIdModel),
    );
  }

  Widget buildTitle() {
    return Text(
      "Student ID",
      textAlign: TextAlign.left,
    );
  }

  Widget buildCardContent(WeatherModel data) {
    return Column(children: <Widget>[
      Text('Student ID Card content'),
    ]);
  }
}
