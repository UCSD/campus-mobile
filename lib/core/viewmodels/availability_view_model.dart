import 'package:campus_mobile/core/models/availability_model.dart';
import 'package:campus_mobile/core/services/availability_service.dart';
import 'package:campus_mobile/ui/widgets/availability/availability_display.dart';
import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/ui/widgets/cards/scroll_view.dart';

class AvailabilityCard extends StatefulWidget {
  @override
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  final AvailabilityService _availabilityService = AvailabilityService();
  Future<List<AvailabilityModel>> _data;

  initState() {
    super.initState();
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailabilityModel>>(
      future: _data,
      builder: (context, snapshot) {
        return CardContainer(
          /// TODO: need to hook up hidden to state using provider
          hidden: false,
          reload: () => _updateData(),
          isLoading: _availabilityService.isLoading,
          title: Text('Availability'),
          errorText: _availabilityService.error,
          child: buildAvailabilityCard(snapshot),
          actionButtons: buildActionButtons(snapshot.data),
        );
      },
    );
  }

  Widget buildAvailabilityCard(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      print('went here');
      List<AvailabilityModel> data = snapshot.data;
      List<Widget> locationsList = List<Widget>();
      for (AvailabilityModel model in data) {
        locationsList.add(AvailabilityDisplay(
          model: model,
        ));
      }
      return PageView(
        children: locationsList,
      );
    } else {
      return Container();
    }
  }

  void _updateData() {
    if (!_availabilityService.isLoading) {
      setState(() {
        _data = _availabilityService.fetchData();
      });
    }
  }

  List<Widget> buildActionButtons(List<AvailabilityModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.BaseLineView);
      },
    ));
    return actionButtons;
  }
}
