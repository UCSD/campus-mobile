import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Flat list of every parking structure and lot, each with an on/off switch
/// that controls whether it appears on the parking card.
class ManageParkingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ContainerView(child: buildLocationsList(context));

  Widget buildLocationsList(BuildContext context) {
    final parkingDataProvider = Provider.of<ParkingDataProvider>(context);

    if (parkingDataProvider.isLoading == true) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary));
    }

    if (parkingDataProvider.error != null) {
      return _statusMessage(context, 'Unable to load parking locations. Please try again later.');
    }

    // Sort by name so each location is easy to find in one list.
    final List<ParkingModel> locations = List<ParkingModel>.from(parkingDataProvider.parkingModels)
      ..sort((a, b) => a.locationName.toLowerCase().compareTo(b.locationName.toLowerCase()));

    if (locations.isEmpty) {
      return _statusMessage(context, 'No parking locations available.');
    }

    final Map<String, bool> viewState = parkingDataProvider.parkingViewState;
    final int selectedLots = viewState.values.where((selected) => selected).length;

    final List<Widget> listTiles = [
      for (ParkingModel location in locations)
        _locationTile(
          context,
          parkingDataProvider,
          location.locationName,
          viewState[location.locationName] ?? false,
          selectedLots,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: ListTile.divideTiles(
          tiles: listTiles,
          context: context,
          color: Theme.of(context).brightness == Brightness.dark ? listTileDividerColorDark : listTileDividerColorLight,
        ).toList(),
      ),
    );
  }

  Widget _locationTile(
    BuildContext context,
    ParkingDataProvider parkingDataProvider,
    String locationName,
    bool isSelected,
    int selectedLots,
  ) {
    void toggle() {
      if (!isSelected && selectedLots >= ParkingDataProvider.MAX_SELECTED_LOTS) {
        showDialog(
          context: context,
          builder: (context) => AlertDialogWidget(
            type: MessageTypeConstants.ERROR,
            icon: Icons.block_flipped,
            title: ParkingConstants.LOT_MAX_TITLE,
            description: ParkingConstants.LOT_MAX_DESC,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
        return;
      }
      parkingDataProvider.toggleLot(locationName, selectedLots);
    }

    // MergeSemantics lets screen readers announce the name and switch state together.
    return MergeSemantics(
      child: ListTile(
        key: Key(locationName),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Text(locationName, style: Theme.of(context).textTheme.bodyMedium),
        onTap: toggle,
        trailing: Transform.scale(
          scale: 0.9,
          child: CupertinoSwitch(
            value: isSelected,
            activeTrackColor: toggleActiveColor,
            inactiveTrackColor: Colors.grey.shade400,
            onChanged: (_) => toggle(),
          ),
        ),
      ),
    );
  }

  Widget _statusMessage(BuildContext context, String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
    ),
  );
}
