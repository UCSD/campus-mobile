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
                          .esriPOIModels
                          .length,
                      itemBuilder: (BuildContext context, int index) {
                        // Builds the "More Results" list with location Name and Distance
                        return ListTile(
                          title: Text(
                            // As of June 2025 - If updatedName is null, use c3dName.
                            // But c3dName is deprecated and will be removed in the future.
                            Provider.of<MapsDataProvider>(context,
                                        listen: false)
                                    .esriPOIModels[index]
                                    .attributes
                                    .updatedName ??
                                Provider.of<MapsDataProvider>(context,
                                        listen: false)
                                    .esriPOIModels[index]
                                    .attributes
                                    .c3dName ??
                                "Unknown Location",
                          ),
                          trailing: Text(
                            Provider.of<MapsDataProvider>(context,
                                            listen: false)
                                        .esriPOIModels[index]
                                        .distance !=
                                    null
                                ? Provider.of<MapsDataProvider>(context,
                                            listen: false)
                                        .esriPOIModels[index]
                                        .distance!
                                        .toStringAsFixed(1) +
                                    ' mi'
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
            padding: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'SHOW MORE RESULTS',
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
