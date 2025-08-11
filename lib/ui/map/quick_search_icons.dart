import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
// import 'package:arcgis_maps/arcgis_maps.dart'; // Saved for future ESRI Map Integration

/// Points of Interest (POI) quick search icons
/// Find more subclasses in the legend's tab: https://www.arcgis.com/apps/mapviewer/index.html?url=https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Points_Of_Interest/FeatureServer/0&source=sd
class QuickSearchIcons extends StatelessWidget {
  const QuickSearchIcons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LabeledIconButton(
              icon: Icons.local_parking,
              text: 'Parking',
              onPressed: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text = 'Parking Structures';
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations(true);
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.coronavirus_outlined,
              text: 'COVID Tests',
              onPressed: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text = 'COVID Test Kits';
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations(true);
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_drink,
              text: 'Hydration',
              onPressed: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text = 'Hydration';
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations(true);
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_atm,
              text: 'ATMs',
              onPressed: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text = 'ATMs';
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations(true); // true means using ESRI POI API
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Constructs the button with an icon and a label
class LabeledIconButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final void Function() onPressed;
  LabeledIconButton({this.icon, this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          onPressed: onPressed,
          color: Theme.of(context).brightness == Brightness.light
                ? lightPrimaryColor
                : secondaryColorDark,
          textColor: Colors.white,
          child: Icon(
            icon,
            size: 28,
          ),
          padding: EdgeInsets.all(12),
          shape: CircleBorder(),
        ),
        SizedBox(height: 6),
        Text(text!,
        style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
            )),
      ],
    );
  }
}
