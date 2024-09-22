import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/shuttle/shuttle_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'shuttle';

class ShuttleCard extends StatefulWidget {
  @override
  _ShuttleCardState createState() => _ShuttleCardState();
}

class _ShuttleCardState extends State<ShuttleCard> {
  ShuttleDataProvider _shuttleCardDataProvider = ShuttleDataProvider();
  PageController _controller = PageController();
  List<ArrivingShuttle>? arrivals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shuttleCardDataProvider = Provider.of<ShuttleDataProvider>(context);
  }

  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<ShuttleDataProvider>(context, listen: false)
          .fetchStops(true),
      isLoading: _shuttleCardDataProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: _shuttleCardDataProvider.error,
      child: () => buildShuttleCard(_shuttleCardDataProvider.stopsToRender,
          _shuttleCardDataProvider.arrivalsToRender),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildShuttleCard(List<ShuttleStopModel?> stopsToRender,
      Map<int?, List<ArrivingShuttle>>? arrivalsToRender) {
    print("Stops - ${stopsToRender.length}");
    print("Arrivals - ${arrivalsToRender?.length}");

    // Handle the case where there are no stops to display
    if (stopsToRender.isEmpty) {
      return Center(child: Text('No shuttles found. Please add a stop.'));
    }

    // Lazy loading by using PageView.builder
    return Column(
      children: <Widget>[
        Flexible(
          child: PageView.builder(
            controller: _controller,
            itemCount: stopsToRender.length,
            itemBuilder: (context, index) {
              final stop = stopsToRender[index];
              final arrivingShuttles = arrivalsToRender?[stop?.id];

              return ShuttleDisplay(
                stop: stop,
                arrivingShuttles: arrivingShuttles,
              );
            },
            onPageChanged: (index) {
              // Optional: Handle page change if needed
            },
          ),
        ),
        DotsIndicator(
          controller: _controller,
          itemCount: stopsToRender.length,
          onPageSelected: (int index) {
            _controller.animateToPage(index,
                duration: Duration(seconds: 1), curve: Curves.ease);
          },
        ),
      ],
    );
  }


  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).backgroundColor,
      ),
      child: Text(
        'Manage Shuttle Stops',
      ),
      onPressed: () {
        if (!_shuttleCardDataProvider.isLoading!) {
          Navigator.pushNamed(context, RoutePaths.ManageShuttleView);
        }
      },
    ));
    return actionButtons;
  }
}
