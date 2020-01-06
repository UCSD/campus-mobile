import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';

class DiningMenuList extends StatelessWidget {
  DiningMenuList({Key key, @required this.id}) : super(key: key);
  final String id;
  DiningMenuItemsModel _data;

  @override
  Widget build(BuildContext context) {
    _data = Provider.of<DiningDataProvider>(context, listen: false)
        .getMenuData(this.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFilterButtons(),
        buildDiningMenuList(context),
      ],
    );
  }

  Widget buildDiningMenuList(BuildContext context) {
    DiningMenuItemsModel menu = _data;
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
