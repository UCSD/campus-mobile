import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuickSearchIcons extends StatelessWidget {
  const QuickSearchIcons({
    Key key,
  }) : super(key: key);

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
                    .text = 'Parking';
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations();
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
                    .fetchLocations();
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
                    .fetchLocations();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_atm,
              text: 'ATM',
              onPressed: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text = 'ATM';
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LabeledIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onPressed;
  LabeledIconButton({this.icon, this.text, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            shape: CircleBorder(),
            primary: Colors.red, // foreground
          ),
          child: Icon(
            icon,
            size: 28,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(text),
      ],
    );
  }
}
