import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/parking/circular_parking_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  // Initialize the ParkingGetX controller and have it fetch data
  ParkingGetX parkingController = Get.put(ParkingGetX());

  final _controller = new PageController();
  String cardId = 'parking';

  @override
  Widget build(BuildContext context) {
    // Build the parking card widget
    return Obx(() => CardContainer(
          // Set card title
          titleText: CardTitleConstants.titleMap[cardId],
          // Check if card is loading
          isLoading: parkingController.isLoading.value,
          // Reload function for refreshing data
          reload: () => {parkingController.fetchParkingData()},
          // Error message
          errorText: parkingController.error.value,
          // Child widget containing parking card content
          child: () => buildParkingCard(context),
          // Check if card is active
          active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
          // Hide function for toggling card visibility
          hide: () => Provider.of<CardsDataProvider>(context, listen: false)
              .toggleCard(cardId),
          // Action buttons for managing lots and spots
          actionButtons: buildActionButtons(),
        ));
  }

  // Build the content of the parking card
  Widget buildParkingCard(BuildContext context) {
    try {
      List<Widget> selectedLotsViews = [];
      // Iterate over parking models to display selected lots
      for (ParkingModel model in parkingController.parkingModels) {
        if (parkingController.parkingViewState.value![model.locationName] ==
            true) {
          selectedLotsViews.add(CircularParkingIndicators(model: model));
        }
      }
      // If no lots are selected, display a message
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
      // Display selected lots with a PageView and dots indicator
      return Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _controller,
              children: selectedLotsViews,
            ),
          ),
          DotsIndicator(
            controller: _controller,
            itemCount: selectedLotsViews.length,
            onPageSelected: (int index) {
              _controller.animateToPage(index,
                  duration: Duration(seconds: 1), curve: Curves.decelerate);
            },
          ),
        ],
      );
    } catch (e) {
      // Handle any errors that occur during widget build
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

  // Build action buttons for managing lots and spots
  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = [];
    // Button for managing lots
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Lots',
      ),
      onPressed: () {
        Get.toNamed(RoutePaths.ManageParkingView, arguments: callSetState);
      },
    ));
    // Button for managing spots
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Spots',
      ),
      onPressed: () {
        Get.toNamed(RoutePaths.SpotTypesView, arguments: callSetState);
      },
    ));
    return actionButtons;
  }

  // Function to trigger state update
  void callSetState() {
    setState(() {});
  }
}
