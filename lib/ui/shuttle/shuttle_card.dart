import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_display.dart';

const String cardId = 'shuttle';

class ShuttleCard extends StatefulWidget {
  @override
  _ShuttleCardState createState() => _ShuttleCardState();
}

class _ShuttleCardState extends State<ShuttleCard> {
  /// STATES
  List<ArrivingShuttle>? arrivals;

  /// PROVIDERS
  ShuttleDataProvider _shuttleCardDataProvider = ShuttleDataProvider();

  /// SERVICES
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shuttleCardDataProvider = Provider.of<ShuttleDataProvider>(context);
  }

  Widget build(BuildContext context) {
    return CardContainer(
      active: context.select((CardsDataProvider p) => p.cardStates[cardId] ?? false),
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () {
        setState(() {
          _currentPage = 0;
        });
        Provider.of<ShuttleDataProvider>(context, listen: false).fetchStops(true);
      },
      isLoading: _shuttleCardDataProvider.isLoading,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: _shuttleCardDataProvider.error,
      child: () => buildShuttleCard(_shuttleCardDataProvider.stopsToRender, _shuttleCardDataProvider.arrivalsToRender),
      actionButtons: [
        ActionLink(
            buttonText: 'MANAGE SHUTTLE STOPS',
            onPressed: () {
              setState(() {
                _currentPage = 0;
              });
              Navigator.pushNamed(context, RoutePaths.MANAGE_SHUTTLE_VIEW);
            }),
      ],
    );
  }

  Widget buildShuttleCard(List<ShuttleStopModel> stopsToRender, Map<int, List<ArrivingShuttle>> arrivalsToRender) {
    List<Widget> renderList = [];
    try {
      // Initialize first shuttle display with arrival information
      if (stopsToRender.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 42.0),
          child: Center(child: Text('No shuttles found. Please add a stop.')),
        );
      }

      // TODO: Reuse if you want to show the closest stop, let's say in the "Manage Shuttle Stops" screen, delete if not needed - December 2025
      // if (_shuttleCardDataProvider.closestStop != null) {
      //   renderList.add(ShuttleDisplay(
      //       stop: _shuttleCardDataProvider.closestStop!,
      //       arrivingShuttles:
      //           arrivalsToRender[_shuttleCardDataProvider.closestStop!.id]));
      // }

      // Display all the shuttle stops with their respective arrivals
      for (var i = 0; i < _shuttleCardDataProvider.stopsToRender.length; i++) {
        renderList.add(ShuttleDisplay(
            stop: _shuttleCardDataProvider.stopsToRender[i],
            arrivingShuttles: arrivalsToRender[_shuttleCardDataProvider.stopsToRender[i].id]));
      }
      return Column(
        children: <Widget>[
          Flexible(
            child: PageView(
              controller: _controller,
              children: renderList,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          DotsIndicator(
            position: _currentPage.toDouble(),
            dotsCount: renderList.length,
            decorator: DotsDecorator(
              color: dotsUnselectedColor,
              activeColor:
                  Theme.of(context).brightness == Brightness.dark ? dotsSelectedColorDark : dotsSelectedColorLight,
              activeSize: const Size(22.0, 22.0),
              size: const Size(10.0, 10.0),
            ),
          )
        ],
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        child: Center(
          child: Text('An error occurred, please try again. ${e.toString()}'),
        ),
      );
    }
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Text(
        'Manage Shuttle Stops',
      ),
      onPressed: () {
        final bool isNotLoading = !_shuttleCardDataProvider.isLoading;
        if (isNotLoading) Navigator.pushNamed(context, RoutePaths.MANAGE_SHUTTLE_VIEW);
      },
    ));
    return actionButtons;
  }
}
