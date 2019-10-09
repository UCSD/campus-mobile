import 'package:campus_mobile/core/models/availability_model.dart';
import 'package:campus_mobile/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/core/services/networking.dart';

class AvailabilityCard extends StatefulWidget {
  @override
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  final NetworkHelper _availabilityService =
      NetworkHelper("https://api-qa.ucsd.edu:8243/occuspace/v1.0/busyness");
  Future<List<AvailabilityModel>> _data;
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
      print(snapshot.data);
      return Container(child: Text('this worked'));
    } else {
      return Container(
        child: Text("error"),
      );
    }
  }

  void _updateData() {
    final Map<String, String> headers = {
      "accept": ":application/json",
      "Authorization": "Bearer " + "\$MOBILE_PUBLIC_BEARER_TOKEN",
    };
    if (!_availabilityService.isLoading) {
      setState(() {
        _data = _availabilityService.authorizedFetch(headers);
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
