import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreESRIResultsList extends StatefulWidget {
  const MoreESRIResultsList({Key? key}) : super(key: key);

  @override
  State<MoreESRIResultsList> createState() => _MoreESRIResultsListState();
}

class _MoreESRIResultsListState extends State<MoreESRIResultsList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                final esriPOIModels = Provider.of<MapsDataProvider>(context, listen: false).esriPOIModels;
                final totalResults = esriPOIModels.length;
                int displayedCount = 50;
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    // Recalculate on every build
                    final showLoadMore = displayedCount < totalResults;
                    final itemCount = showLoadMore ? displayedCount + 1 : totalResults;
                    return Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            'More Results',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(height: 0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: itemCount,
                            itemBuilder: (BuildContext context, int index) {
                              // Determine the names that will be shown to the user
                              final poi = Provider.of<MapsDataProvider>(context, listen: false).esriPOIModels[index];
                              final attributes = poi.attributes;
                              // As of August 2025 - If updatedName is null, use {Subclass} + {Facility Long Name}.
                              final title = attributes.updatedName ??
                                  ((attributes.subclass != null &&
                                      attributes.facilityLongName != null)
                                      ? attributes.subclass! +
                                      ' - ' +
                                      attributes.facilityLongName!
                                      : 'Unknown Location');
                              // If we don't know the location, don't show it in the list
                              if (title == 'Unknown Location') return const SizedBox.shrink();
                              // Create the `Load More` button if we are at the end
                              // of the first 50 items, and there are more to load.
                              if (index == displayedCount && showLoadMore) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setModalState(() {
                                          displayedCount = (displayedCount + 50).clamp(0, totalResults);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: actionButtonBackgroundColor,
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'LOAD MORE',
                                        style: TextStyle(
                                          color: lightPrimaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              // Show the "More Results" list with the first 50 locations Names determined above
                              return ListTile(
                                title: Text(title),
                                trailing: Text(
                                  poi.distance != null
                                      ? poi.distance!.toStringAsFixed(1) + ' mi'
                                      : '--',
                                  style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? linkColorLight
                                          : linkColorDark),
                                ),
                                onTap: () {
                                  Provider.of<MapsDataProvider>(context, listen: false).addMarker(index);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: actionButtonBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'MORE RESULTS',
            style: TextStyle(
              color: lightPrimaryColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
