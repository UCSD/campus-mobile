import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),
        Provider.of<DiningDataProvider>(context).isLoading
            ? CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary)
            : buildDiningMenuList(context),
      ],
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
                      color: Theme.of(context).colorScheme.background,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: " (\$${item.price})",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
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
            SizedBox(height: 30),
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
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Checkbox(
                semanticLabel: 'Vegetarian',
                value:
                    Provider.of<DiningDataProvider>(context).filtersSelected[0],
                onChanged: (bool? value) {
                  setState(() {
                    Provider.of<DiningDataProvider>(context, listen: false)
                        .filtersSelected[0] = value!;
                  });
                },
                checkColor: Colors.black, // Black mark
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white; // White background when selected
                    }
                    return Colors.white; // Default background
                  },
                ),
                side: WidgetStateBorderSide.resolveWith(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? unselectedIconDarkColor
                              : unselectedIconLightColor); // Black border when selected
                    }
                    return BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? unselectedIconDarkColor
                            : unselectedIconLightColor); // Default border
                  },
                ),
              ),
              Text('Vegetarian', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                semanticLabel: 'Vegan',
                value:
                    Provider.of<DiningDataProvider>(context).filtersSelected[1],
                onChanged: (bool? value) {
                  setState(() {
                    Provider.of<DiningDataProvider>(context, listen: false)
                        .filtersSelected[1] = value!;
                  });
                },
                checkColor: Colors.black, // Black mark
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white; // White background when selected
                    }
                    return Colors.white; // Default background
                  },
                ),
                side: WidgetStateBorderSide.resolveWith(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? unselectedIconDarkColor
                              : unselectedIconLightColor); // Black border when selected
                    }
                    return BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? unselectedIconDarkColor
                            : unselectedIconLightColor); // Default border
                  },
                ),
              ),
              Text('Vegan', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                semanticLabel: 'Gluten-free',
                value:
                    Provider.of<DiningDataProvider>(context).filtersSelected[2],
                onChanged: (bool? value) {
                  setState(() {
                    Provider.of<DiningDataProvider>(context, listen: false)
                        .filtersSelected[2] = value!;
                  });
                },
                checkColor: Colors.black, // Black mark
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white; // White background when selected
                    }
                    return Colors.white; // Default background
                  },
                ),
                side: WidgetStateBorderSide.resolveWith(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? unselectedIconDarkColor
                              : unselectedIconLightColor); // Black border when selected
                    }
                    return BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? unselectedIconDarkColor
                            : unselectedIconLightColor); // Default border
                  },
                ),
              ),
              Text('Gluten-free', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
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
  final title;
  final Meal value;
  final Meal groupValue;
  final void Function(Meal?)? onChanged;

  const LabeledRadio(
      {Key? key,
      required this.title,
      required this.value,
      required this.groupValue,
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
            activeColor: Theme.of(context).colorScheme.background,
          ),
          Container(
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
