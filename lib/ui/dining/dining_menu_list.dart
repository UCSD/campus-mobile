import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiningMenuList extends StatefulWidget {
  DiningMenuList({Key? key, required this.model}) : super(key: key);
  final DiningModel model;

  @override
  _DiningMenuListState createState() => _DiningMenuListState();
}

class _DiningMenuListState extends State<DiningMenuList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Provider.of<DiningDataProvider>(context).isLoading!
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary)
          : buildDiningMenuList(context),
    );
  }

  Widget buildDiningMenuList(BuildContext context) {
    DiningMenuItemsModel? menu =
        Provider.of<DiningDataProvider>(context, listen: false)
            .getMenuData(widget.model.id);
    List<String> filters = [];
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
    switch (Provider.of<DiningDataProvider>(context, listen: false).mealTime) {
      case Meal.breakfast:
        filters.add('Breakfast');
        break;
      case Meal.lunch:
        filters.add('Lunch');
        break;
      case Meal.dinner:
        filters.add('Dinner');
    }
    if (menu!.menuItems != null) {
      List<DiningMenuItem> menuList =
          Provider.of<DiningDataProvider>(context, listen: false)
              .getMenuItems(widget.model.id, filters)!;
      List<Widget> list = [];
      if (menuList.length > 0) {
        for (DiningMenuItem item in menuList) {
          list.add(GestureDetector(
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item.name,
                    style: TextStyle(
                      // color: Theme.of(context).buttonColor,
                      color: Theme.of(context).backgroundColor,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: " (\$${item.price})",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2!.color),
                  )
                ],
              ),
            ),
            onTap: () {
              Object args = {
                "data": item,
                "disclaimer": menu.disclaimer,
                "disclaimerEmail": menu.disclaimerEmail
              };
              Navigator.pushNamed(context, RoutePaths.DiningNutritionView,
                  arguments: args);
            },
          ));
        }
      } else {
        return Column(
          children: <Widget>[
            buildFilterButtons(context),
            buildMealButtons(context),
            SizedBox(height: 10),
            Center(child: Text('No items match your filter.')),
          ],
        );
      }
      return Column(
        children: <Widget>[
          buildFilterButtons(context),
          buildMealButtons(context),
          SizedBox(height: 10),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
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
    } else if (widget.model.url != null && widget.model.url!.isNotEmpty) {
      return Center(
        child: Text('Menu not directly available. Try checking their website.'),
      );
    } else
      return Center(
        child: Text('Menu not available.'),
      );
  }

  Widget buildFilterButtons(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: Provider.of<DiningDataProvider>(context).filtersSelected,
        textStyle: TextStyle(fontSize: 18),
        selectedColor: Theme.of(context).textTheme.button!.color,
        // fillColor: Theme.of(context).buttonColor,
        fillColor: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(10),
        constraints: BoxConstraints.expand(
            width: (MediaQuery.of(context).size.width - 40) * .33, height: 38),
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

  Widget buildMealButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LabeledRadio(
            title: 'Breakfast',
            value: Meal.breakfast,
            groupValue: Provider.of<DiningDataProvider>(context).mealTime,
            onChanged: (Meal? value) => setState(() {
                  Provider.of<DiningDataProvider>(context, listen: false)
                      .mealTime = value!;
                })),
        LabeledRadio(
          title: 'Lunch',
          value: Meal.lunch,
          groupValue: Provider.of<DiningDataProvider>(context).mealTime,
          onChanged: (Meal? value) {
            setState(() {
              Provider.of<DiningDataProvider>(context, listen: false).mealTime =
                  value!;
            });
          },
        ),
        LabeledRadio(
            title: 'Dinner',
            value: Meal.dinner,
            groupValue: Provider.of<DiningDataProvider>(context).mealTime,
            onChanged: (Meal? value) => setState(() {
                  Provider.of<DiningDataProvider>(context, listen: false)
                      .mealTime = value!;
                })),
      ],
    );
  }
}

class LabeledRadio extends StatelessWidget {
  final String? title;
  final Meal value;
  final Meal? groupValue;
  final void Function(Meal?)? onChanged;

  const LabeledRadio(
      {Key? key,
      this.title,
      required this.value,
      this.groupValue,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            // activeColor: Theme.of(context).buttonColor,
            activeColor: Theme.of(context).backgroundColor,
          ),
          Container(
            child: Text(
              title!,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
