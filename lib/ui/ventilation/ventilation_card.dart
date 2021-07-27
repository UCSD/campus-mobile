import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/ventilation/ventilation_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'ventilation';

class VentilationCard extends StatefulWidget {
  @override
  _VentilationCardState createState() => _VentilationCardState();
}

class _VentilationCardState extends State<VentilationCard> {
  PageController _controller = PageController(initialPage: 0);
  VentilationDataProvider _ventilationDataProvider = VentilationDataProvider();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ventilationDataProvider = Provider.of<VentilationDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      //null
      reload: () => Provider.of<VentilationDataProvider>(context, listen: false)
          .fetchVentilationData(),
      //false
      isLoading: _ventilationDataProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      //null
      errorText: _ventilationDataProvider.error,
      child: () =>
          buildCardContent(_ventilationDataProvider.ventilationDataModels),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildCardContent(List<VentilationDataModel?> models) {
    print("Length in card: ${models.length}");

    List<Widget> displays = [];
    for (VentilationDataModel? model in models) {
      displays.add(VentilationDisplay(
        model: model,
      ));
    }

    if (displays.length == 0) {
      displays.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Locations to Display",
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Add Locations via 'Manage Locations'",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ],
      ));
    }

    return Column(
      children: <Widget>[
        // for some reason only wrapping PageView in a container or SizedBox works
        // Flexible and Expanded do not work
        Container(
          height: 150,
          child: PageView(
            controller: _controller,
            children: displays,
          ),
        ),
        DotsIndicator(
          controller: _controller,
          itemCount: displays.length,
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
        primary: Theme.of(context).buttonColor,
      ),
      child: Text(
        'Manage Locations',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.VentilationBuildings,
            arguments: _ventilationDataProvider.ventilationLocations);
      },
    ));
    return actionButtons;
  }
}
