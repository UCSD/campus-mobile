import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/parking/circular_parking_indicator.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  static const cardId = 'parking';

  late ParkingDataProvider _parkingDataProvider;

  final _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
  }

  // ignore: must_call_super
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      titleText: CardTitleConstants.titleMap[cardId]!,
      isLoading: _parkingDataProvider.isLoading,
      reload: () => {_parkingDataProvider.fetchParkingData()},
      errorText: _parkingDataProvider.error,
      child: () => buildParkingCard(context),
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      actionButtons: [
        ActionButton(
            buttonText: 'MANAGE SPOTS',
            onPressed: () =>
                Navigator.pushNamed(context, RoutePaths.SpotTypesView)),
        ActionLink(
            buttonText: 'MANAGE LOTS',
            onPressed: () =>
                Navigator.pushNamed(context, RoutePaths.ManageParkingView)),
      ],
    );
  }

  Widget buildParkingCard(BuildContext context) {
    try {
      List<Widget> selectedLotsViews = [];
      for (ParkingModel model in _parkingDataProvider.parkingModels) {
        if (_parkingDataProvider.parkingViewState[model.locationName] == true) {
          selectedLotsViews.add(CircularParkingIndicators(model: model));
        }
      }

      if (selectedLotsViews.isEmpty) {
        return (Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Lots to Display",
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Add a Lot via 'Manage Lots'",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
      }

      return Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: selectedLotsViews.length,
              physics: BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return selectedLotsViews[index];
              },
            ),
          ),
          DotsIndicator(
            position: _currentPage.toDouble(),
            dotsCount: selectedLotsViews.length,
            decorator: DotsDecorator(
              color: dotsUnselectedColor,
              activeColor: Theme.of(context).brightness == Brightness.dark
                  ? dotsSelectedColorDark
                  : dotsSelectedColorLight,
              activeSize: const Size(22.0, 22.0),
              size: const Size(10.0, 10.0),
            ),
          ),
        ],
      );
    } catch (e) {
      print(e);
      return Container(
        width: double.infinity,
        child: Center(
          child: Container(
            child: Text('An error occurred, please try again.'),
          ),
        ),
      );
    }
  }
}
