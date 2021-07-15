import 'package:campus_mobile_experimental/app_constants.dart';
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
  late VentilationDataProvider _ventilationDataProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ventilationDataProvider = Provider.of<VentilationDataProvider>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("Context in ventilation card: $context");
    List<Widget> data = [];

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(data),
      actionButtons: buildActionButtons(),
    );
  }

  Widget buildCardContent(List<Widget> locationsList) {
    int numPages = 3;
    VentilationDisplay.numPages = numPages;

    return Column(
      children: <Widget>[
        Container(
          height: 150,
          child: PageView(
            controller: _controller,
            children: VentilationDisplay().buildPages(),
          ),
        ),
        DotsIndicator(
          controller: _controller,
          itemCount: numPages,
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
        Navigator.pushNamed(context, RoutePaths.VentilationBuildings);
      },
    ));
    return actionButtons;
  }
}
