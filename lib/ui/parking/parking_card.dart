import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/parking/circular_parking_indicator.dart';
import 'package:campus_mobile_experimental/ui/parking/manage_parking_view.dart';
import 'package:campus_mobile_experimental/ui/parking/spot_types_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class ParkingCard extends StatefulWidget {
  @override
  _ParkingCardState createState() => _ParkingCardState();
}

class _ParkingCardState extends State<ParkingCard> {
  // Initialize the NewsGetX controller and have it fetch data
  ParkingGetX parkingController = Get.put(ParkingGetX());

  // late ParkingDataProvider _parkingDataProvider;
  final _controller = new PageController();
  String cardId = 'parking';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parkingController = Get.find();
    // _parkingDataProvider = Provider.of<ParkingDataProvider>(context);
  }

  // ignore: must_call_super
  Widget build(BuildContext context) {
    Map<String, Function> menuOption = {
      "Manage Lots": (context) =>
          {Navigator.pushNamed(context, RoutePaths.ManageParkingView)},
      "Manage Spots": (context) =>
          {Navigator.pushNamed(context, RoutePaths.SpotTypesView)}
    };
    //super.build(context);
    return Obx(() => CardContainer(
          titleText: CardTitleConstants.titleMap[cardId],
          isLoading: parkingController.isLoading.value,
          reload: () => {parkingController.fetchParkingData()},
          errorText: parkingController.error.value,
          child: () => buildParkingCard(context),
          active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
          hide: () => Provider.of<CardsDataProvider>(context, listen: false)
              .toggleCard(cardId),
          actionButtons: buildActionButtons(),
        ));
  }

  Widget buildParkingCard(BuildContext context) {
    try {
      List<Widget> selectedLotsViews = [];
      for (ParkingModel model in parkingController.parkingModels) {
        if (parkingController.parkingViewState.value![model.locationName] ==
            true) {
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

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Lots',
      ),
      onPressed: () {
        // Navigator.pushNamed(context, RoutePaths.ManageParkingView);
        Get.to(() => ManageParkingView());
      },
    ));
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Spots',
      ),
      onPressed: () {
        // Navigator.pushNamed(context, RoutePaths.SpotTypesView);
        Get.to(() => SpotTypesView());
      },
    ));
    return actionButtons;
  }
}
