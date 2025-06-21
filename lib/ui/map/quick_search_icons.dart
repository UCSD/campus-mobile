import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_styles.dart';
// import 'package:arcgis_maps/arcgis_maps.dart'; // Saved for future ESRI Map Integration

/// Found in the legend's tab: https://www.arcgis.com/apps/mapviewer/index.html?url=https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Points_Of_Interest/FeatureServer/0&source=sd
final subclasses = [
  'ATMs',
  'Athletic Facilities',
  'Baby Changing Stations',
  'Book Return',
  'Broadcast Towers',
  'COVID Test Kits',
  'Cafes and Restaurants',
  'Call Boxes',
  'Career Services',
  'Catering',
  'Classrooms',
  'Clean Energy',
  'Coffee',
  'Collections',
  'Compost Locations',
  'Computer Labs',
  'Conference Rooms',
  'Department Offices',
  'Electric Vehicle Charging',
  'Emergency Care',
  'Emergency Containers',
  'Gardens',
  'Gender Inclusive',
  'Global Initiatives',
  'Hydration',
  'Imprints',
  'Information',
  'Information Services',
  'Kiosks',
  'LEED Certified Buildings',
  'Lactation',
  'Laundry',
  'Loading Docks',
  'Lounges',
  'Mail Boxes',
  'Mail Offices',
  'Markets',
  'Medical Clinics',
  'Memorial',
  'Metropolitan Transit System (MTS)',
  'North County Transit District (NCTD)',
  'Parking Entrances',
  'Parking Offices',
  'Parking Pay Stations',
  'Parking Structures',
  'Pay Phones',
  'Police',
  'Public',
  'Recreation Facilities',
  'Research and Innovation',
  'Research/Labs',
  'Retail',
  'SPIN Hubs',
  'Showers',
  'Special',
  'Speciality Recycling Locations',
  'Stryker Chairs',
  'Stuart Collection',
  'Student Organizations',
  'Student Services',
  'Sustainability',
  'Triton Mobility Services',
  'Vending Machines',
  'WayPoints'
];

/// Points of Interest (POI) quick search icons
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
