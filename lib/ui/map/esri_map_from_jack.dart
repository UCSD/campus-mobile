import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

class EsriMaps extends StatefulWidget {
  @override
  _EsriMapsState createState() => _EsriMapsState();
}

class _EsriMapsState extends State<EsriMaps> {
  final _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic);
  final _mapViewController = ArcGISMapView.createController();
  final _textEditingController = TextEditingController();

  final List<Map<String, String>> _layerOptions = [
    {
      'name': 'Buildings',
      'url':
      'https://services9.arcgis.com/mXNwDpiENQiMIzRv/arcgis/rest/services/aa002e/FeatureServer/0',
    },
    {
      'name': 'Resources',
      'url':
      'https://services1.arcgis.com/eGSDp8lpKe5izqVc/arcgis/rest/services/UCSD_on_campus_resources_2_WFL1/FeatureServer/0',
    },
    {
      'name': 'Regions',
      'url':
      'https://services1.arcgis.com/eGSDp8lpKe5izqVc/arcgis/rest/services/UCSD_Regions_2014/FeatureServer/0',
    },
    {
      'name': 'POIs',
      'url':
      'https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Points_Of_Interest/FeatureServer/0',
    },
  ];

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

  late ServiceFeatureTable _featureTable;
  late FeatureLayer _featureLayer;
  ManualDisplayFilterDefinition? _displayFilterDefinition;

  String _currentLayerName = 'Buildings';
  String _message = '';
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    ArcGISEnvironment.apiKey =
    'AAPTxy8BH1VEsoebNVZXo8HurEBECxvQNl6npvATkbb_hlcfhfk79rCfKobWrsCcCmQweTxAFJBE9fJ-1TkjS0p-g1FP66bFWCf4wCndJBDLUIDaQMTFwe2spC_xe_TM6D03tEp47Bj9_1kjxhWECOxgsf61xi_HdThJnG04h7tseaSMG2xVQAovU4RQwiMjCHb15BCaGW5rPqt0_VbB1ogchLzpuxHI4gLW4wzJihTee3I.AT1_jIaJXaPU';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: _dismissSearch,
                    icon: const Icon(Icons.clear),
                  ),
                ),
                onSubmitted: _onSearchSubmitted,
              ),
              Expanded(
                child: Stack(
                  children: [
                    ArcGISMapView(
                      controllerProvider: () => _mapViewController,
                      onMapViewReady: _onMapViewReady,
                      onTap: _onTap,
                    ),
                    if (_message.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.black.withOpacity(0.7),
                          child: Text(
                            _message,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _showLayerSelection,
                  child: const Icon(Icons.layers),
                ),
                if (_currentLayerName == 'POIs')
                  const SizedBox(height: 10),
                if (_currentLayerName == 'POIs')
                  FloatingActionButton(
                    onPressed: _showPOIFilterSelection,
                    child: const Icon(Icons.filter_list),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapViewReady() {
    _mapViewController.arcGISMap = _map;
    _loadFeatureServiceFromUri(_layerOptions[0]['url']!);
    setState(() {
      _mapReady = true;
    });
  }

  void _loadFeatureServiceFromUri(String url) {
    final uri = Uri.parse(url);
    _featureTable = ServiceFeatureTable.withUri(uri);
    _featureLayer = FeatureLayer.withFeatureTable(_featureTable);

    _map.operationalLayers.clear();
    _map.operationalLayers.add(_featureLayer);

    _mapViewController.setViewpoint(
      Viewpoint.withLatLongScale(
        latitude: 32.8801,
        longitude: -117.2341,
        scale: 60000,
      ),
    );
  }

  void _switchFeatureLayer(String layerName, String url) {
    setState(() {
      _currentLayerName = layerName;
      _displayFilterDefinition = null;
      _loadFeatureServiceFromUri(url);
      _message = 'Switched to $layerName Layer';
    });
  }

  void _showLayerSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _layerOptions.length,
          itemBuilder: (context, index) {
            final layer = _layerOptions[index];
            return ListTile(
              title: Text(layer['name']!),
              onTap: () {
                Navigator.pop(context);
                _switchFeatureLayer(layer['name']!, layer['url']!);
              },
            );
          },
        );
      },
    );
  }

  void _showPOIFilterSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _poiClasses.length,
          itemBuilder: (context, index) {
            final category = _poiClasses[index];
            return ListTile(
              title: Text(category),
              onTap: () {
                Navigator.pop(context);
                _applyPOIDisplayFilter(category);
              },
            );
          },
        );
      },
    );
  }

  void _applyPOIDisplayFilter(String category) {
    final displayFilter = DisplayFilter.withWhereClause(
      name: category,
      whereClause: "Class = '$category'",
    );

    setState(() {
      _displayFilterDefinition = ManualDisplayFilterDefinition.withFilters(
        activeFilter: displayFilter,
        availableFilters: [displayFilter],
      );
      _featureLayer.displayFilterDefinition = _displayFilterDefinition;
      _message = 'Filtered POIs: $category';
    });
  }

  void _dismissSearch() {
    setState(() => _textEditingController.clear());
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _onSearchSubmitted(String value) async {
    // Implement search logic
  }

  void _onTap(Offset localPosition) async {
    // Implement tap logic
  }
}