import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/services/dining_service.dart';

class DiningMenuList extends StatefulWidget {
  final String id;
  const DiningMenuList({Key key, @required this.id}) : super(key: key);
  @override
  _DiningMenuListState createState() => _DiningMenuListState();
}

class _DiningMenuListState extends State<DiningMenuList> {
  final DiningService _diningService = DiningService();
  Future<DiningMenuItemsModel> _data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_diningService.isLoading) {
      setState(() {
        _data = _diningService.fetchMenu(this.widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DiningMenuItemsModel>(
      future: _data,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFilterButtons(),
                  buildDiningMenuList(snapshot, context),
                ],
              )
            : Column();
      },
    );
  }

  Widget buildDiningMenuList(AsyncSnapshot snapshot, BuildContext context) {
    DiningMenuItemsModel menu = snapshot.data;
    List<MenuItem> menuList = menu.menuItems;
    List<Widget> list = List<Widget>();
    if (menuList != null) {
      for (MenuItem item in menuList) {
        list.add(GestureDetector(
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              children: [
                TextSpan(
                  text: item.name,
                  style:
                      TextStyle(color: Theme.of(context).textTheme.body1.color),
                ),
                TextSpan(
                  text: " (${item.price})",
                  style:
                      TextStyle(color: Theme.of(context).textTheme.body1.color),
                )
              ],
            ),
          ),
          onTap: () {
            ///TODO navigate to nutrition page for this item
            Navigator.pushNamed(context, RoutePaths.DiningNutritionView,
                arguments: {
                  "data": item,
                  "disclaimer": menu.disclaimer,
                  "disclaimerEmail": menu.disclaimerEmail
                });
          },
        ));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      );
    } else {
      return Container();
    }
  }

  ///TODO build buttons to filter food items
  Widget buildFilterButtons() {
    return Row();
  }
}
