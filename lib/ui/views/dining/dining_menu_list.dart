import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiningMenuList extends StatelessWidget {
  DiningMenuList({Key key, @required this.id}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Provider.of<DiningDataProvider>(context).isLoading
          ? CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFilterButtons(),
                Container(child: buildDiningMenuList(context)),
              ],
            ),
    );
  }

  Widget buildDiningMenuList(BuildContext context) {
    DiningMenuItemsModel menu =
        Provider.of<DiningDataProvider>(context, listen: false).getMenuData(id);
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
                  style: TextStyle(
                    color: Theme.of(context).buttonColor,
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: " (\$${item.price})",
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
      return ListView.separated(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return list[index];
        },
        separatorBuilder: (context, index) {
          return Divider(height: 8);
        },
        itemCount: list.length,
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
