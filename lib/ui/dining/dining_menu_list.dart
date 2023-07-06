import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/dining_query.dart';

class DiningMenuList extends HookWidget {
  late ValueNotifier<Meal> mealTime;
  late ValueNotifier<List<bool>> filtersSelected;

  DiningMenuList({Key? key, required this.model}) : super(key: key);
  final DiningModel model;

  @override
  Widget build(BuildContext context) {
    mealTime = useState(Meal.breakfast);
    filtersSelected = useState([false, false, false]);

    return Center(
      child: Provider.of<DiningDataProvider>(context).isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary)
          : buildDiningMenuList(context),
    );
  }

  Widget buildDiningMenuList(BuildContext context) {
    Map<String, DiningMenuItemsModel?> diningMenuItemModels =
        Provider.of<DiningDataProvider>(context).getDiningMenuItemModels();
    DiningMenuItemsModel menu;
    if (model.id != null) {
      // TODO CHANGE OUT CONDITIONAL QUERY
      final diningMenuHook = useFetchDiningMenuModels(model.id!);
      if (diningMenuItemModels[model.id] != null) {
        menu = diningMenuItemModels[model.id]!;
      } else {
        // while (diningMenuHook.isFetching) {} // waits until dining hook has fetched -- TEMPORARY: Replace/Restructure architecture to wait for hook to load after removing provider
        diningMenuItemModels[model.id!] = diningMenuHook.data;
        menu = DiningMenuItemsModel();
      }
    } else {
      menu = DiningMenuItemsModel();
    }

    // menu =
    //     Provider.of<DiningDataProvider>(context, listen: false)
    //         .getMenuData(model.id);
    List<String> filters = [];
    if (filtersSelected.value[0]) {
      filters.add('VT');
    }
    if (filtersSelected.value[1]) {
      filters.add('VG');
    }
    if (filtersSelected.value[2]) {
      filters.add('GF');
    }
    switch (mealTime.value) {
      case Meal.breakfast:
        filters.add('Breakfast');
        break;
      case Meal.lunch:
        filters.add('Lunch');
        break;
      case Meal.dinner:
        filters.add('Dinner');
    }
    if (menu.menuItems != null) {
      List<DiningMenuItem> menuList =
          Provider.of<DiningDataProvider>(context, listen: false)
              .getMenuItems(model.id, filters)!;
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
    } else if (model.url != null && model.url!.isNotEmpty) {
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
        isSelected: filtersSelected.value,
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
        onPressed: (int index) => filtersSelected.value[index] = !filtersSelected.value[index],
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
            groupValue: mealTime.value,
            onChanged: (Meal? value) => mealTime.value = value!),
        LabeledRadio(
            title: 'Lunch',
            value: Meal.lunch,
            groupValue: mealTime.value,
            onChanged: (Meal? value) => mealTime.value = value!
        ),
        LabeledRadio(
            title: 'Dinner',
            value: Meal.dinner,
            groupValue: mealTime.value,
            onChanged: (Meal? value) => mealTime.value = value!),
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
