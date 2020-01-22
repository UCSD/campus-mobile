import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/core/data_providers/weather_data_provider.dart';

class CardsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WeatherDataProvider weatherData = Provider.of<WeatherDataProvider>(context);
    return ContainerView(
      child: Center(
        child: weatherData.isHidden ? Text('weather hidden') : Text('weather active'),
      ),
    );
  }
}
