import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_display.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/availability_query.dart';

const cardId = 'availability';

class AvailabilityCard extends HookWidget
{
  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    final userDataProvider = useMemoized(() {
      debugPrint("Memoized UserDataProvider!");
      return Provider.of<UserDataProvider>(context);
    }, [context]);
    useListenable(userDataProvider);

    final availability = useFetchAvailabilityModels();
    debugPrint("AvailabilityCard: SUCCESSFULLY LOADED DATA!");

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => availability.refetch(),
      isLoading: availability.isFetching,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: availability.isError ? "" : null, // TODO: figure out what to do with errorText
      child: () =>
          buildAvailabilityCard(availability.data!, controller, userDataProvider),
      actionButtons: buildActionButtons(context), // TODO: figure out if this can be useContext
    );
  }

  Widget buildAvailabilityCard(List<AvailabilityModel?> data, PageController controller, UserDataProvider userDataProvider) {
    List<Widget> locationsList = [];

    for (AvailabilityModel? model in data) {
      if (model != null) {
        if (!userDataProvider.userProfileModel!.isOccuspaceLocationDisabled(model.name!)) {
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

  List<Widget> buildActionButtons(BuildContext context) {
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
        Navigator.pushNamed(context, RoutePaths.ManageAvailabilityView);
      },
    ));
    return actionButtons;
  }
}
