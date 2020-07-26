import 'package:campus_mobile_experimental/core/data_providers/spot_types_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class SpotTypesView extends StatelessWidget {
  SpotTypesDataProvider _spotTypesDataProvider;
  // UserDataProvider _userDataProvider;
  @override
  Widget build(BuildContext context) {
    _spotTypesDataProvider = Provider.of<SpotTypesDataProvider>(context);
    // _userDataProvider = Provider.of<UserDataProvider>(context);
    return ContainerView(
      child: createListWidget(_spotTypesDataProvider.spotTypeModel),
    );
  }

  Widget createListWidget(SpotTypeModel model) {
    return ListView(children: createList(model));
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
      ],
    );
  }

  List<Widget> createList(SpotTypeModel model) {
    List<Widget> list = List<Widget>();
    // _spotTypesDataProvider.fetchSpotTypes();
    for (Spot data in model.spots) {
      print(data.spotKey);
      list.add(ListTile(
        leading: Container(
            width: 35, // TODO add responsive units
            height: 35,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image:
                        new NetworkImage("https://i.imgur.com/wQYnFtM.jpg")))),
//        leading: Icon(Icons.reorder),
        key: Key(data.spotKey),
        title: Text(data.name),
        // trailing: Switch(
        //   value: _userDataProvider
        //       .userProfileModel.selectedParkingSpots[data.spotKey],
        //   onChanged: (_) {
        //     _userDataProvider.toggleSpotTypeSelection(data.spotKey);
        //   },
          // activeColor: ColorPrimary,
        // ),
      ));
    }
    return list;
  }
}
