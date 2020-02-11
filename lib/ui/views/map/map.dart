import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/maps_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/map_search_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  GoogleMapController _mapController;

  LatLng _center = const LatLng(32.8801, -117.2341);

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (Provider.of<MapsDataProvider>(context).markers.isNotEmpty &&
        _mapController != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(
          Provider.of<MapsDataProvider>(context)
              .markers
              .values
              .toList()[0]
              .position));
    }
    if (Provider.of<MapsDataProvider>(context).coordinates != null) {
      _center = LatLng(Provider.of<MapsDataProvider>(context).coordinates.lat,
          Provider.of<MapsDataProvider>(context).coordinates.lon);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  List<Widget> createTiles(BuildContext context) {
    List<Widget> list = List<Widget>();
    int listIndex = 0;
    for (MapSearchModel i
        in Provider.of<MapsDataProvider>(context).mapSearchModels) {
      list.add(aLocation(i, context, listIndex++));
    }
    return ListTile.divideTiles(tiles: list, context: context).toList();
  }

  Widget aLocation(MapSearchModel data, BuildContext context, int index) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(
        data.title,
      ),
      trailing: Text(
        data.distance != null
            ? data.distance.toStringAsPrecision(3) + ' mi'
            : '--',
        style: TextStyle(color: Colors.blue[600]),
      ),
      onTap: () {
        Provider.of<MapsDataProvider>(context, listen: false).addMarker(index);
        Navigator.pop(context);
      },
    );
  }

  Widget noResults() {
    if (Provider.of<MapsDataProvider>(context).noResults) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('No results found for your search.')));
      });
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          markers: Set<Marker>.of(
              Provider.of<MapsDataProvider>(context).markers.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.5,
          ),
        ),
        Hero(
          tag: 'search_bar',
          child: Card(
            margin: EdgeInsets.all(5),
            child: RawMaterialButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutePaths.MapSearch);
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: Provider.of<MapsDataProvider>(context).isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(2.5),
                            child: Container(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator()),
                          )
                        : Icon(
                            Icons.search,
                            size: 30,
                          ),
                  ),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: Provider.of<MapsDataProvider>(context)
                          .searchBarController,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: 'Search',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              child: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              backgroundColor: Colors.lightBlue,
              onPressed: () {
                _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .coordinates
                        .lat,
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .coordinates
                        .lon)));
              },
            ),
          ),
        ),
        Provider.of<MapsDataProvider>(context).markers.isNotEmpty
            ? Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      //isScrollControlled: true,
                      context: context,
                      builder: (context) => Column(
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
                          Divider(
                            height: 0,
                          ),
                          Expanded(
                            child: ListView(
                              children: createTiles(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  color: Theme.of(context).buttonColor,
                  child: Text(
                    'Show More Results',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.button.color),
                  ),
                ),
              )
            : noResults(),
      ],
    );
  }
}
