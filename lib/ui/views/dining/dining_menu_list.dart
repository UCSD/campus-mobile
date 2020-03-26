import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiningMenuList extends StatefulWidget {
  DiningMenuList({Key key, @required this.id}) : super(key: key);
  final String id;

  @override
  _DiningMenuListState createState() => _DiningMenuListState();
}

class _DiningMenuListState extends State<DiningMenuList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Provider.of<DiningDataProvider>(context).isLoading
          ? CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(child: buildDiningMenuList(context)),
              ],
            ),
    );
  }

  Widget buildDiningMenuList(BuildContext context) {
    DiningMenuItemsModel menu =
        Provider.of<DiningDataProvider>(context, listen: false)
            .getMenuData(widget.id);
    List<String> filters = List<String>();
    if (Provider.of<DiningDataProvider>(context, listen: false)
        .filtersSelected[0]) {
      filters.add('VT');
    }
    if (Provider.of<DiningDataProvider>(context, listen: false)
        .filtersSelected[1]) {
      filters.add('VG');
    }
    if (Provider.of<DiningDataProvider>(context, listen: false)
        .filtersSelected[2]) {
      filters.add('GF');
    }
    List<MenuItem> menuList =
        Provider.of<DiningDataProvider>(context, listen: false)
            .getMenuItems(widget.id, filters);
    List<Widget> list = List<Widget>();
    if (menuList != null) {
      if (menuList.length > 0) {
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
                    style: TextStyle(
                        color: Theme.of(context).textTheme.body1.color),
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
      } else {
        return Column(
          children: <Widget>[
            buildFilterButtons(context),
            SizedBox(height: 10),
            Center(child: Text('No items match your filter.')),
          ],
        );
      }
      return Column(
        children: <Widget>[
          buildFilterButtons(context),
          SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) {
              return list[index];
            },
            separatorBuilder: (context, index) {
              return Divider(height: 8);
            },
            itemCount: list.length,
          ),
        ],
      );
    } else {
      return Center(
        child: Text('Menu not available.'),
      );
    }
  }

  ///TODO build buttons to filter food items
  Widget buildFilterButtons(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: Provider.of<DiningDataProvider>(context).filtersSelected,
        textStyle: TextStyle(fontSize: 18),
        selectedColor: Theme.of(context).textTheme.button.color,
        fillColor: Theme.of(context).buttonColor,
        borderRadius: BorderRadius.circular(10),
        constraints: BoxConstraints.expand(width: 120, height: 38),
        children: <Widget>[
          Text('Vegetarian'),
          Text('Vegan'),
          Text('Gluten-free'),
        ],
        onPressed: (int index) {
          setState(() {
            Provider.of<DiningDataProvider>(context, listen: false)
                    .filtersSelected[index] =
                !Provider.of<DiningDataProvider>(context, listen: false)
                    .filtersSelected[index];
          });
        },
      ),
    );
  }
}
