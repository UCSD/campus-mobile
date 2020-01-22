import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/availability_model.dart';
import 'package:campus_mobile_experimental/ui/cards/availability/availability_display.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:provider/provider.dart';

class AvailabilityCard extends StatefulWidget {
  @override
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  final _controller = PageController();
  AvailabilityDataProvider _availabilityDataProvider;

  void _updateData() {
    if (!_availabilityDataProvider.isLoading) {
      _availabilityDataProvider.fetchAvailability();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
      hidden: _availabilityDataProvider.isHidden,
      hide: () => _availabilityDataProvider.toggleHide(),
      reload: () => _updateData(),
      isLoading: _availabilityDataProvider.isLoading,
      title: Text('Availability'),
      errorText: _availabilityDataProvider.error,
      child: () =>
          buildAvailabilityCard(_availabilityDataProvider.availabilityModels),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildAvailabilityCard(List<AvailabilityModel> data) {
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
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'Manage Locations',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ManageAvailabilityView);
      },
    ));
    return actionButtons;
  }
}
