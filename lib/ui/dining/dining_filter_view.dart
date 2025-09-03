import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_styles.dart';
import '../common/container_view.dart';
import '../../core/providers/dining.dart';

/// View for dining payment filter settings
/// This displays a list of filter types with on/off switches to toggle
/// Uses DiningDataProvider's ```diningFilterTypeStates``` to manage
/// the toggle state of each filter type to filter accordingly.
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
    // For each filter type available, create a ListTile with a switch
    // ```type``` is the filter type's name (i.e. "Triton Cash")
    // See DiningConstants.payment_filter_types for all available filter types
    for (String type in typesAvailable) {
      filterTypesList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            // Use the ```type``` as the unique string key
            key: Key(type),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                type, // Display the filter type's name
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            // Display a switch button at the end of each ListTile
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch.adaptive(
                // Each filter type's switch is 'on' or 'off' based on the filter type's state
                value: diningProvider.diningFilterTypeStates[type]!, // Remember that ```type``` is a string key (i.e. "Triton Cash")
                onChanged: (_) {
                  // On changed, this calls the provider function that "toggles" the filter type's state
                  // i.e. if "Triton Cash" was on (true), it makes it off (false).
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
