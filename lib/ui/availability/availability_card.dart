import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_display.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'availability';

class AvailabilityCard extends StatefulWidget {
  @override
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  /// PROVIDERS
  late AvailabilityDataProvider _availabilityDataProvider;

  /// SERVICES
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => _availabilityDataProvider.fetchAvailability(),
      isLoading: _availabilityDataProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId]!,
      errorText: _availabilityDataProvider.error,
      child: () =>
          buildAvailabilityCard(_availabilityDataProvider.availabilityModels),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildAvailabilityCard(List<AvailabilityModel?> data) {
    List<Widget> locationsList = [];
    final multiPager = RegExp(r' \(\d+/\d+\)$');
    // loop through all the models, adding each one to locationsList
    for (AvailabilityModel? model in data) {
      if (model != null) {
        String curName = model.name;
        RegExpMatch? match = multiPager.firstMatch(curName);
        if (match != null)
          curName = curName.replaceRange(match.start, match.end, '');
        if (_availabilityDataProvider.locationViewState[curName]!) {
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
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          child: PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: locationsList,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DotsIndicator(
            position: _currentPage.toDouble(),
            dotsCount: locationsList.length,
            decorator: DotsDecorator(
              color: dotsUnselectedColor,
              activeColor: Theme.of(context).brightness == Brightness.dark
                  ? dotsSelectedColorDark
                  : dotsSelectedColorLight,
              activeSize: const Size(22.0, 22.0),
              size: const Size(10.0, 10.0),
            ),
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
        foregroundColor: Theme.of(context).colorScheme.background,
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
