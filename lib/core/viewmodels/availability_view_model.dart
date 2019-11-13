import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/core/services/availability_service.dart';
import 'package:campus_mobile_beta/ui/widgets/availability/availability_display.dart';
import 'package:campus_mobile_beta/ui/widgets/cards/card_container.dart';
import 'package:campus_mobile_beta/ui/widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:provider/provider.dart';

class AvailabilityCard extends StatefulWidget {
  @override
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  final _controller = PageController();
  AvailabilityService _availabilityService;
  bool hidden;

  void _updateData() {
    if (!_availabilityService.isLoading) {
      _availabilityService.fetchData();
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _availabilityService = Provider.of<AvailabilityService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      hidden: false,
      reload: () => _updateData(),
      isLoading: _availabilityService.isLoading,
      title: Text('Availability'),
      errorText: _availabilityService.error,
      child: buildAvailabilityCard(_availabilityService.data),
      actionButtons: buildActionButtons(_availabilityService.data),
    );
  }

  Widget buildAvailabilityCard(List<AvailabilityModel> data) {
    if (data != null && data.length > 0) {
      List<Widget> locationsList = List<Widget>();
      for (AvailabilityModel model in data) {
        locationsList.add(AvailabilityDisplay(
          model: model,
        ));
      }

      return Column(
        children: <Widget>[
          Flexible(
            child: PageView(
              controller: _controller,
              children: locationsList,
            ),
          ),
          DotsIndicator(
            controller: _controller,
            itemCount: data.length,
            onPageSelected: (int index) {
              _controller.animateToPage(index,
                  duration: Duration(seconds: 1), curve: Curves.ease);
            },
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  List<Widget> buildActionButtons(List<AvailabilityModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'Manage Locations',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ManageAvailabilityView,
            arguments: data);
      },
    ));
    return actionButtons;
  }
}
