import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreESRIResultsList extends StatelessWidget {
  const MoreESRIResultsList({
    Key? key,
  }) : super(key: key);

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
              builder: (context) => Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      'More Results',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(
                    height: 0,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Provider.of<MapsDataProvider>(context)
                          .mapSearchModels
                          .length,
                      // Builds the "More Results" list with location Name and Distance
                      itemBuilder: (BuildContext context, int index) {
                        final poi = Provider.of<MapsDataProvider>(context, listen: false).mapSearchModels[index];
                        final attributes = poi.attributes;
                        // As of August 2025 - If updatedName is null, use {Subclass} + {Facility Long Name}.
                        final title = attributes.UpdatedName ??
                            ((attributes.Subclass != null &&
                                    attributes.FacilityLongName != null)
                                ? attributes.Subclass! +
                                    ' - ' +
                                    attributes.FacilityLongName!
                                : 'Unknown Location');
                        // If we don't know the location, don't show it in the list
                        if (title == 'Unknown Location') return const SizedBox.shrink();
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
                            Provider.of<MapsDataProvider>(context,
                                    listen: false)
                                .addMarker(index);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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
