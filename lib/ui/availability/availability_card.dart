import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_constants.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_display.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const cardId = 'availability';

class AvailabilityCard extends StatefulWidget {
  @override
  _AvailabilityCardState createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> with WidgetsBindingObserver {
  static const _refreshInterval = Duration(seconds: 90);

  /// PROVIDERS
  late AvailabilityDataProvider _availabilityDataProvider;
  late CardsDataProvider _cardsDataProvider;
  late BottomNavigationBarProvider _bottomNavigationBarProvider;

  /// SERVICES
  final _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;
  AppLifecycleState? _lifecycleState;

  @override
  void initState() {
    super.initState();
    _lifecycleState = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);
    _cardsDataProvider = Provider.of<CardsDataProvider>(context);
    _bottomNavigationBarProvider = Provider.of<BottomNavigationBarProvider>(context);
    _updatePolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _updatePolling();
  }

  bool get _isActive =>
      mounted &&
      (_cardsDataProvider.cardStates[cardId] ?? false) &&
      _bottomNavigationBarProvider.currentIndex == NavigatorConstants.HOME_TAB &&
      _lifecycleState == AppLifecycleState.resumed;

  void _updatePolling() {
    if (!_isActive) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    if (_timer != null) return;
    final timer = _timer = Timer.periodic(_refreshInterval, (_) {
      if (_isActive) _availabilityDataProvider.fetchAvailability(silent: true);
    });

    // Defer fetching until after build so provider notifications are safe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isActive || _timer != timer) return;
      final lastUpdated = _availabilityDataProvider.lastUpdated;
      if (lastUpdated == null || DateTime.now().difference(lastUpdated) >= _refreshInterval) {
        _availabilityDataProvider.fetchAvailability(silent: true);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        Flexible(
          child: ActionLink(
            buttonText: 'MANAGE LOCATIONS',
            onPressed: () {
              analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'manage'});
              Navigator.pushNamed(context, RoutePaths.MANAGE_AVAILABILITY_VIEW);
            },
          ),
        ),
      ],
      footer: _availabilityDataProvider.lastUpdated == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LastUpdatedWidget(time: _availabilityDataProvider.lastUpdated!),
                    if (_availabilityDataProvider.refreshFailed)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Unable to refresh. Showing last available data.',
                          style: Theme.of(context).brightness == Brightness.dark
                              ? descriptiveTextSmallDark
                              : descriptiveTextSmallLight,
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: LOCATION_FONT_SIZE),
              ),
              padding: EdgeInsets.only(bottom: TITLE_BOTTOM_PADDING),
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
                  activeColor: Theme.of(context).brightness == Brightness.dark
                      ? dotsSelectedColorDark
                      : dotsSelectedColorLight,
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
