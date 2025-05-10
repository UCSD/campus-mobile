import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'esri_map_from_jack.dart';

final List<String> _poiClasses = [
  'Academic and Admin',
  'Art',
  'Athletic Facilities',
  'Dining and Beverage',
  'Emergency',
  'Events',
  'Healthcare',
  'Information',
  'Library',
  'Loading Docks',
  'Mobility',
  'Recreation Facilities',
  'Restrooms',
  'Services',
  'Shopping',
  'Student Services',
  'Sustainability',
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
              onPressed: () => _applyPOIDisplayFilter('Parking'),
            ),
            LabeledIconButton(
              icon: Icons.coronavirus_outlined,
              text: 'COVID Tests',
              onPressed: () => _applyPOIDisplayFilter('COVID Test Kits'),
            ),
            LabeledIconButton(
              icon: Icons.local_drink,
              text: 'Hydration',
              onPressed: () => _applyPOIDisplayFilter('Hydration'),
            ),
            LabeledIconButton(
              icon: Icons.local_atm,
              text: 'ATM',
              onPressed: () => _applyPOIDisplayFilter('ATM'),
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
  final Function? onPressed;
  LabeledIconButton({this.icon, this.text, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          onPressed: onPressed as void Function()?,
          color: Colors.red,
          textColor: Colors.white,
          child: Icon(
            icon,
            size: 28,
          ),
          padding: EdgeInsets.all(12),
          shape: CircleBorder(),
        ),
        SizedBox(height: 6),
        Text(text!),
      ],
    );
  }
}
