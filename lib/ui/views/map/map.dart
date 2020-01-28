import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/map_search_model.dart';
import 'package:campus_mobile_experimental/core/services/map_search_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final MapSearchService _mapSearchService = MapSearchService();
  GoogleMapController _mapController;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  List<MapSearchModel> _data;
  TextEditingController _searchBarController;
  bool _isSearching = false;
  var location = new Location();

  final LatLng _center = const LatLng(32.8911637, -117.2428029);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _getData(String text, TextEditingController searchController) async {
    _searchBarController = searchController;
    _markers.clear();
    _isSearching = true;
    _data = await _mapSearchService.fetchMenu(text);
    setState(() {
      _isSearching = false;
    });
    if (_data.isNotEmpty) {
      _addMarker(0);
    } else {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('No results found for your search.')));
    }
  }

  void _addMarker(int listIndex) {
    final Marker marker = Marker(
      markerId: MarkerId(_data[listIndex].mkrMarkerid.toString()),
      position: LatLng(_data[listIndex].mkrLat, _data[listIndex].mkrLong),
      infoWindow: InfoWindow(title: _data[listIndex].title),
    );
    setState(() {
      _markers.clear();
      _markers[marker.markerId] = marker;
      _mapController.animateCamera(CameraUpdate.newLatLng(marker.position));
    });
  }

  List<Widget> createTiles(BuildContext context) {
    List<Widget> list = List<Widget>();
    int listIndex = 0;
    for (var i in _data) {
      list.add(aLocation(i, context, listIndex++));
    }
    return ListTile.divideTiles(tiles: list, context: context).toList();
  }

  Widget aLocation(MapSearchModel data, BuildContext context, int index) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(data.title),
      trailing: Text(' mi'),
      onTap: () {
        _addMarker(index);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          markers: Set<Marker>.of(_markers.values),
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
                Navigator.pushNamed(context, RoutePaths.MapSearch,
                    arguments: _getData);
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: _isSearching
                        ? Container(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator())
                        : Icon(
                            Icons.search,
                            size: 30,
                          ),
                  ),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: _searchBarController,
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
                setState(() {
                  _mapController.animateCamera(
                      CameraUpdate.newLatLng(_center)); //TODO: Goto my location
                });
              },
            ),
          ),
        ),
        _markers.isNotEmpty
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
                            child: Text('More Results'),
                          ),
                          Expanded(
                            child: ListView(
                              children: createTiles(context),
                            ),
                          ),
                        ],
                      ),
                    );
//                    Navigator.pushNamed(context, RoutePaths.MapLocationList,
//                        arguments: {'data': _data, 'addMarker': _addMarker});
                  },
                  color: Theme.of(context).buttonColor,
                  child: Text(
                    'Show More Results',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.button.color),
                  ),
                ),
              )
            : Container(
                height: 0,
              )
      ],
    );
  }
}
