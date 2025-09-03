import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_styles.dart';
import '../common/container_view.dart';
import '../../core/providers/dining.dart';

class DiningFilterView extends StatelessWidget {
  DiningFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerView(
        child: buildSettingsList(context, DiningConstants.payment_filter_types)
    );
  }

  Widget buildSettingsList(BuildContext context, List<String> topicsData) {
    final diningProvider = Provider.of<DiningDataProvider>(context);
    return (Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: createList(context, topicsData, diningProvider),
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ).toList(),
      ),
    ));
  }

  // Creates a list of tiles containing filter types with switches
  List<Widget> createList(BuildContext context, List<String> typesAvailable,
      DiningDataProvider diningProvider) {
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
                value: diningProvider.diningFilterTypeStates[type]!,
                onChanged: (_) {
                  diningProvider.toggleFilterType(type);
                },
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
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
