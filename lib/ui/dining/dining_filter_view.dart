import 'package:flutter/material.dart';
import '../../app_styles.dart';
import '../common/container_view.dart';

class DiningFilterView extends StatelessWidget {
  DiningFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerView(
        child: buildSettingsList(context, payment_filter_types));
  }

  Widget buildSettingsList(BuildContext context, List<String> topicsData) {
    return (Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: createList(context, topicsData),
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ).toList(),
      ),
    ));
  }

  final payment_filter_types = [
    "Triton Cash",
    "Dining Dollars",
    "Apple/Google Pay",
    "MaterCard, Visa",
    "American Express",
    "Cash",
    "Other",
  ];

  // Creates a list of tiles containing filter types with switches
  List<Widget> createList(BuildContext context, List<String> typesAvailable) {
    List<Widget> filterTypesList = [];
    for (String type in typesAvailable) {
      filterTypesList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            // Use the type as a unique key
            key: Key(type),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                type, // Display the filter type name (i.e. "Triton Cash")
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            // Add a switch to the end of the ListTile
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch.adaptive(
                value: true, // TODO: Switch is always on (placeholder)
                onChanged: (value) {

                }, // TODO: No action on change (placeholder)
                activeColor: toggleActiveColor,
              ),
            ),
          ),
        ),
      );
    }
    // Return the list of filter types to display
    return filterTypesList;
  }
}
