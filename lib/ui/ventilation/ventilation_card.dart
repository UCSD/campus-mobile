import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_data.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/ventilation/ventilation_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

const String cardId = 'ventilation';

class VentilationCard extends StatefulWidget {
  @override
  _VentilationCardState createState() => _VentilationCardState();
}

class _VentilationCardState extends State<VentilationCard> {
  PageController _controller = PageController();
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
      reload: () => _ventilationDataProvider.fetchVentilationData(),
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
    var display;
    try {
      for (VentilationDataModel? model in models) {
        if (model != null) {
          display = VentilationDisplay(
            model: model,
          );
        }
      }
      if (display == null) {
        return (Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Location to Display",
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Add a Location via 'Manage Location'",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
      }
      return Column(
        children: <Widget>[
          Container(
            child: display,
          ),
        ],
      );
    } catch (e) {
      print(e);
      return Container(
        width: double.infinity,
        child: Center(
          child: Container(
            child: Text('An error occurred, please try again.' + e.toString()),
          ),
        ),
      );
    }
  }

  List<Widget> buildActionButtons() {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        primary: Theme.of(context).buttonColor,
      ),
      child: Text(
        'Manage Location',
      ),
      onPressed: () {
        if (!_ventilationDataProvider.isLoading!) {
          Navigator.pushNamed(context, RoutePaths.VentilationBuildings,
              arguments: _ventilationDataProvider.ventilationLocations);
        }
      },
    ));
    return actionButtons;
  }
}
