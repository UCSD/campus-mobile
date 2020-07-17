import 'package:campus_mobile_experimental/core/data_providers/spot_types_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class SpotTypesView extends StatelessWidget {
  SpotTypesDataProvider _spotTypesDataProvider;
  @override
  Widget build(BuildContext context) {
    _spotTypesDataProvider = Provider.of<SpotTypesDataProvider>(context);
    _spotTypesDataProvider.fetchSpotTypes();
    return ContainerView(
      child: createListWidget(context),
    );
  }

  Widget createListWidget(BuildContext context) {
      return ListView(children: createList(context));
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
      ],
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    // _spotTypesDataProvider.fetchSpotTypes();
    for (Spot data in _spotTypesDataProvider.spotTypeModel.spots) {
      print(data.spotKey);
      list.add(ListTile(
//        leading: Icon(Icons.reorder),
        key: Key(data.spotKey),
        title: Text(data.name),
        // trailing: Switch(
        //   value: _cardsDataProvider.cardStates[card],
        //   onChanged: (_) {
        //     _cardsDataProvider.toggleCard(card);
        //   },
        // activeColor: ColorPrimary,
        // ),
      ));
    }
    return list;
  }
}
