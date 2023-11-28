import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuickSearchIcons extends StatelessWidget {
  final void Function() fetchLocations;
  final TextEditingController searchBarController;

  const QuickSearchIcons({
    Key? key,
    required this.fetchLocations,
    required this.searchBarController,
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
                searchBarController.text = 'Parking';
                fetchLocations();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.coronavirus_outlined,
              text: 'COVID Tests',
              onPressed: () {
                searchBarController.text = 'COVID Test Kits';
                fetchLocations();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_drink,
              text: 'Hydration',
              onPressed: () {
                searchBarController.text = 'Hydration';
                fetchLocations();
                Navigator.pop(context);
              },
            ),
            LabeledIconButton(
              icon: Icons.local_atm,
              text: 'ATM',
              onPressed: () {
                searchBarController.text = 'ATM';
                fetchLocations();
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
