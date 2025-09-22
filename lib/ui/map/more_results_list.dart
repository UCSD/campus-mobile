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
                // Get all POIs
                final allPOIs =
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .mapSearchModels;
                // Separate TopResult == "1" and TopResult == "0"
                final topResults = allPOIs
                    .where((poi) => poi.attributes.TopResult == "1")
                    .toList();
                final otherResults = allPOIs
                    .where((poi) => poi.attributes.TopResult == "0")
                    .toList();
                // Sort each by distance ascending
                topResults.sort((a, b) => (a.distance ?? double.infinity)
                    .compareTo(b.distance ?? double.infinity));
                otherResults.sort((a, b) => (a.distance ?? double.infinity)
                    .compareTo(b.distance ?? double.infinity));
                // Concatenate
                final sortedPOIs = [...topResults, ...otherResults];
                final totalResults = allPOIs.length;
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(height: 0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemCount,
                        // Builds the "More Results" list with location Name and Distance
                        itemBuilder: (BuildContext context, int index) {
                          final poi = sortedPOIs[index];
                          final attributes = poi.attributes;
                          // As of August 2025 - If updatedName is null, use {Subclass} + {Facility Long Name}.
                          /// TODO: Move this title logic to the lambda
                          final title = getPOITitle(attributes);
                          // If we don't know the location, don't show it in the list
                          if (title == 'Unknown Location')
                            return const SizedBox.shrink();
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
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? linkColorLight
                                      : linkColorDark),
                            ),
                            onTap: () {
                              Provider.of<MapsDataProvider>(context,
                                      listen: false)
                                  .addMarker(allPOIs.indexOf(poi));
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
          },);
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

String getPOITitle(dynamic attributes) {
  if (attributes.UpdatedName != null) {
    if (int.tryParse(attributes.UpdatedName!) != null) {
      return attributes.Subclass != null
          ? attributes.Subclass! + ' - ' + attributes.UpdatedName!
          : attributes.UpdatedName!;
    } else {
      return attributes.UpdatedName!;
    }
  } else if (attributes.Subclass != null && attributes.FacilityLongName != null) {
    return attributes.Subclass! + ' - ' + attributes.FacilityLongName!;
  } else if (attributes.FacilityLongName != null) {
    return attributes.FacilityLongName!;
  } else {
    return 'Unknown Location';
  }
}
