import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_display.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 90), (_) => _availabilityDataProvider.fetchAvailability(silent: true));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      cardId: cardId,
      active: context.select((CardsDataProvider p) => p.cardStates[cardId] ?? false),
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () {
        setState(() {
          _currentPage = 0;
        });
        // check at least one is enabled to avoid crash
        if (_controller.hasClients)
          _controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        _availabilityDataProvider.fetchAvailability();
      },
      isLoading: _availabilityDataProvider.isLoading,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: _availabilityDataProvider.error,
      child: () => buildAvailabilityCard(_availabilityDataProvider.availabilityModels),
      actionButtons: [
        ActionLink(
            buttonText: 'MANAGE LOCATIONS',
            onPressed: () {
              analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'manage'});
              Navigator.pushNamed(context, RoutePaths.MANAGE_AVAILABILITY_VIEW);
            }),
        if (_availabilityDataProvider.lastUpdated != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: Text(
                'Live · Updated ${DateFormat.jm().format(_availabilityDataProvider.lastUpdated!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
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
        if (match != null) curName = curName.replaceRange(match.start, match.end, '');
        final bool shouldShowLocation = _availabilityDataProvider.locationViewState[curName] ?? false;
        if (shouldShowLocation) locationsList.add(AvailabilityDisplay(model: model));
      }
    }

    // the user chose no location, so instead show "No Location to Display"
    if (locationsList.length == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
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
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
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
            child: Container(
              margin: const EdgeInsets.only(top: 30.0),
              child: DotsIndicator(
                position: _currentPage.clamp(0, locationsList.length - 1).toDouble(),
                dotsCount: locationsList.length,
                decorator: DotsDecorator(
                  color: dotsUnselectedColor,
                  activeColor:
                      Theme.of(context).brightness == Brightness.dark ? dotsSelectedColorDark : dotsSelectedColorLight,
                  activeSize: const Size(22.0, 22.0),
                  size: const Size(10.0, 10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
