import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/core/services/dining_service.dart';
import 'package:campus_mobile_experimental/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/views/dining/dining_list.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, asin;

class DiningCard extends StatefulWidget {
  @override
  _DiningState createState() => _DiningState();
}

class _DiningState extends State<DiningCard> {
  DiningService _diningService;
  Coordinates _location;
  bool hidden;

  _updateData() async {
    if (!_diningService.isLoading) {
      _diningService.fetchData();
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _location = Provider.of<Coordinates>(context);

    _diningService = Provider.of<DiningService>(context);
    populateDistances(_location, _diningService.data);
  }

  populateDistances(Coordinates userLocation, List<DiningModel> data) {
    for (DiningModel model in data) {
      if (model.coordinates != null) {
        model.distance = calculateDistance(userLocation.lat, userLocation.lon,
                model.coordinates.lat, model.coordinates.lon) *
            0.00062137;
      }
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

  Widget buildDiningCard(List<DiningModel> data) {
    if (data.length > 0) {
      return DiningList(
        data: data,
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
        Navigator.pushNamed(context, RoutePaths.DiningViewAll, arguments: data);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      hidden: false,
      reload: () => _updateData(),
      isLoading: _diningService.isLoading,
      title: buildTitle("Dining"),
      errorText: _diningService.error,
      child: buildDiningCard(_diningService.data),
      actionButtons: buildActionButtons(_diningService.data),
    );
  }
}
