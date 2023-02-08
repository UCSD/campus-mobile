import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_display.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

const cardId = 'availability';

class AvailabilityCard extends HookWidget
{
  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    final availabilityDataProvider = useMemoized(
            () => Provider.of<AvailabilityDataProvider>(context)
    );
    useListenable(availabilityDataProvider);

    // final availabilityModelList = useAuthorizedFetchData(
    //     "https://api-qa.ucsd.edu:8243/campusbusyness/v1/busyness", {
    //       "Authorization": "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    // });

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => availabilityDataProvider.fetchAvailability(),
      isLoading: availabilityDataProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: availabilityDataProvider.error,
      child: () =>
          buildAvailabilityCard(availabilityDataProvider.availabilityModels, controller, availabilityDataProvider),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildAvailabilityCard(List<AvailabilityModel?> data, PageController controller, AvailabilityDataProvider provider) {
    List<Widget> locationsList = [];

    // loop through all the models, adding each one to locationsList
    for (AvailabilityModel? model in data) {
      if (model != null) {
        if (provider.locationViewState[model.name]!) {
          locationsList.add(AvailabilityDisplay(model: model));
        }
      }
    }

    // the user chose no location, so instead show "No Location to Display"
    if (locationsList.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text(
              "No Location to Display",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: LOCATION_FONT_SIZE,
              ),
            ),
            padding: EdgeInsets.only(
              bottom: TITLE_BOTTOM_PADDING,
            ),
          ),
          Text("Add Locations via 'Manage Locations'"),
        ],
      );
    }

    return Column(
      children: <Widget>[
        Flexible(
          child: PageView(
            controller: controller,
            children: locationsList,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DotsIndicator(
            controller: controller,
            itemCount: locationsList.length,
            onPageSelected: (int index) {
              controller.animateToPage(index,
                  duration: Duration(seconds: 1), curve: Curves.ease);
            },
          ),
        )
      ],
    );
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(useContext()).backgroundColor,
      ),
      child: Text(
        'Manage Locations',
      ),
      onPressed: () {
        Navigator.pushNamed(useContext(), RoutePaths.ManageAvailabilityView);
      },
    ));
    return actionButtons;
  }
}
