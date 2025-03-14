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

class _DiningMenuListState extends State<DiningMenuList>
{
  @override
  Widget build(BuildContext context) =>
    Center(
      child: context.watch<DiningDataProvider>().isLoading
        ? CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary)
        : buildDiningMenuList(),
    );

  Widget buildDiningMenuList() {
    final diningDataProvider = context.read<DiningDataProvider>();
    final menu = diningDataProvider.getMenuData(widget.model.id);
    List<String> filters = [];

    if (diningDataProvider.filtersSelected[0])
      filters.add('VT');

    if (diningDataProvider.filtersSelected[1])
      filters.add('VG');

    if (diningDataProvider.filtersSelected[2])
      filters.add('GF');

    filters.add(switch (diningDataProvider.mealTime) {
      Meal.breakfast => 'Breakfast',
      Meal.lunch => 'Lunch',
      Meal.dinner => 'Dinner'
    });

    if (menu == null || menu.menuItems == null)
      return Center(
        child: Text(widget.model.url != null && widget.model.url!.isNotEmpty
          ? 'Menu not directly available. Try checking their website.'
          : 'Menu not available.'
        ),
      );
    
    final menuList = diningDataProvider.getMenuItems(widget.model.id, filters)!;
    final list = <Widget>[];

    if (menuList.isEmpty) {
      return Column(
        children: <Widget>[
          buildFilterButtons(),
          buildMealButtons(),
          const SizedBox(height: 10),
          const Center(child: const Text('No items match your filter.')),
        ],
      );
    }
    
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
    
    return Column(
      children: <Widget>[
        buildFilterButtons(),
        buildMealButtons(),
        const SizedBox(height: 10),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, index) => list[index],
          separatorBuilder: (_, __) => const Divider(height: 8),
          itemCount: list.length,
        ),
      ],
    );
  }

  Widget buildFilterButtons() {
    return Center(
      child: ToggleButtons(
        isSelected: context.read<DiningDataProvider>().filtersSelected,
        textStyle: const TextStyle(fontSize: 18),
        selectedColor: Theme.of(context).textTheme.labelLarge!.color,
        // fillColor: Theme.of(context).buttonColor,
        fillColor: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
        constraints: BoxConstraints.expand(
            width: (MediaQuery.of(context).size.width - 40) * .33, height: 38),
        children: const <Widget>[
          const Text('Vegetarian'),
          const Text('Vegan'),
          const Text('Gluten-free'),
        ],
        onPressed: (int index) {
          setState(() {
            final ddp = context.read<DiningDataProvider>();
            ddp.filtersSelected[index] = !ddp.filtersSelected[index];
          });
        },
      ),
    );
  }


  // TODO: fix bug where entire widget reloads if changing meal time
  Widget buildMealButtons() {
    final mealBtnCallback = (Meal? value) {
      setState(() => context.read<DiningDataProvider>().mealTime = value!);
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LabeledRadio(
            title: 'Breakfast',
            value: Meal.breakfast,
            groupValue: context.watch<DiningDataProvider>().mealTime,
            onChanged: mealBtnCallback,
        ),
        LabeledRadio(
          title: 'Lunch',
          value: Meal.lunch,
          groupValue: context.watch<DiningDataProvider>().mealTime,
          onChanged: mealBtnCallback,
        ),
        LabeledRadio(
            title: 'Dinner',
            value: Meal.dinner,
            groupValue: context.watch<DiningDataProvider>().mealTime,
            onChanged: mealBtnCallback,
        ),
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
