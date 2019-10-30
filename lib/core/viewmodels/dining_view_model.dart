import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/core/services/dining_service.dart';
import 'package:campus_mobile_beta/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/ui/views/dining/dining_list.dart';
import 'package:campus_mobile_beta/core/services/locationService.dart';
import 'dart:math' show cos, sqrt, asin;

class DiningCard extends StatefulWidget {
  @override
  _DiningState createState() => _DiningState();
}

class _DiningState extends State<DiningCard> {
  final DiningService _diningService = DiningService();
  Future<List<DiningModel>> _data;
  final LocationService _locationService = LocationService();

  initState() {
    super.initState();
    _updateData();
  }

  populateDistances(Coordinates userLocation) {
    _data.then((listOfDiningHalls) {
      for (DiningModel model in listOfDiningHalls) {
        if (model.coordinates != null) {
          model.distance = calculateDistance(userLocation.lat, userLocation.lon,
                  model.coordinates.lat, model.coordinates.lon) *
              0.00062137;
        }
      }
    });
  }

  _updateData() async {
    if (!_diningService.isLoading) {
      setState(() {
        _data = _diningService.fetchData();
      });
    }
  }

  num calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Widget buildDiningCard(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return DiningList(
        data: _data,
        listSize: 3,
      );
    } else {
      return Container();
    }
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
    );
  }

  List<Widget> buildActionButtons(List<DiningModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.DiningViewAll,
            arguments: _data);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiningModel>>(
      future: _data,
      builder: (context, snapshot) {
        return StreamBuilder<Coordinates>(
            stream: _locationService.locationStream,
            builder: (context, locationData) {
              if (locationData.hasData) populateDistances(locationData.data);
              return CardContainer(
                /// TODO: need to hook up hidden to state using provider
                hidden: false,
                reload: () => _updateData(),
                isLoading: _diningService.isLoading,
                title: buildTitle("Dining"),
                errorText: _diningService.error,
                child: buildDiningCard(snapshot),
                actionButtons: buildActionButtons(snapshot.data),
              );
            });
      },
    );
  }
}
