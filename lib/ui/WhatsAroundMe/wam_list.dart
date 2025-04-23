import 'package:campus_mobile_experimental/ui/WhatsAroundMe/places_list_model.dart';
import 'package:flutter/material.dart';
import '../../app_styles.dart';

/// TODO: Make each place name clickable to open a "place details page" (might need to update router)
/// That would require the "Get Place Details API" ^
/// https://developers.arcgis.com/documentation/mapping-and-location-services/place-finding/get-place-details/

class BuildWhatAroundMeList extends StatelessWidget {
  final List<Place> places;
  const BuildWhatAroundMeList({Key? key, required this.places}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          /// TODO: Make this icon clickable to open directions to specific place in the WAM list
          leading: Icon(
            Icons.directions_walk,
            color: Colors.lightBlue,
          ),
          title: Text(
            place.name,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: lightPrimaryColor
            ),
          ),
          subtitle: Text(
            "${place.location} • ${place.businessHours}",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            "${place.distanceMi.toStringAsFixed(1)} mi",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
