import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:campus_mobile_experimental/core/data_providers/bluetooth_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';

class BluetoothLoggerView extends StatefulWidget {
  // Instantiate Bluetooth Singleton
  final BluetoothSingleton bluetoothScan = BluetoothSingleton();

  @override
  State<StatefulWidget> createState() =>
      _BluetoothLoggerViewState(bluetoothScan);
}

class _BluetoothLoggerViewState extends State<BluetoothLoggerView> {

  // Instantiate the secure storage (will slow down scan)
  final _storage = FlutterSecureStorage();

  // List for secure storage
  List<_SecItem> _items = [];

  // Counter for bluetooth devices found
  int _counter = 0;
  int _scanNumber = 0;

  // Default slider value
  double _cupertinoSliderValue = 2.0;

  // Reference to bluetoothSingleton
  BluetoothSingleton bluetoothSingleton;

  // Lists for rendering devices
  static List currentScanList = [];
  static List ongoingLog = [];
  static List ongoingLogBuffer = [];

  // Reference to listener
  StreamSubscription<List<ScanResult>> subscription;

  // static List deviceServices = [];
  StreamSubscription<LocationData> _locationSubscription;

  // Location instances
  LocationData _currentLocation;
  var _locationService = new Location();
  _BluetoothLoggerViewState(BluetoothSingleton bluetoothScan);

  // State set when location changes
  @override
  void initState() {
    bluetoothSingleton = widget.bluetoothScan;
    super.initState();
    _locationSubscription = _locationService.onLocationChanged
        .listen((LocationData currentLocation) async {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  // Method to process storage
  Future<Null> _readAll() async {
    final all = await _storage.readAll();

    _items =
        all.keys.map((key) => _SecItem(key, all[key])).toList(growable: false);
    print('Secure storage item count is ${_items.length}');
  }

  String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });

    return String.fromCharCodes(codeUnits);
  }

  // Method to start scan and process lists
  void _incrementCounter() {
    _readAll();

    // Instances to keep track of scan # and current run
    _scanNumber++;

    // Counter variable prevent multiple logging
    int ran = 0;

    // Get reference to the bluetooth scan
    FlutterBlue currentInstance = bluetoothSingleton.flutterBlueInstance;

    //Stop ongoing scan
    currentInstance.stopScan();
    bluetoothSingleton.pauseScan();
    bluetoothSingleton.ongoingScanner.cancel();

    // Start a new scan with slider value
    currentInstance.startScan(
        timeout: Duration(seconds: _cupertinoSliderValue.toInt()),
        allowDuplicates: false);

    // Clear the buffer of previously scanned devices
    ongoingLogBuffer.clear();

    // Listen to results asynchronously
    subscription = currentInstance.scanResults.listen((results) async {

      //Reset rendering lists as necessary
      currentScanList.clear();

      // Remove buffer from ongoing log if not final scan
      for (int i = 0; i < ongoingLogBuffer.length; i++) {
        ongoingLog.removeAt(0);
      }
      ongoingLogBuffer.clear();


      // Process scan results
      for (ScanResult r in results) {
        final String key = _randomValue();
        final String value = r.device.id.toString();

        // Add to current scan log
        if (!currentScanList.contains('ID: ${r.device.id}' +
            "\nDevice name: " +
            (r.device.name != "" ? r.device.name : "Unknown") +
            "\n")) {
          currentScanList.add('ID: ${r.device.id}' +
              "\nDevice name: " +
              (r.device.name != "" ? r.device.name : "Unknown") +
              "\n");
        }

        // Add to device log
        if (!ongoingLogBuffer.contains('ID: ${r.device.id}' +
            "\nDevice name: " +
            (r.device.name != "" ? r.device.name : "Unknown") +
            "\n")) {
          ongoingLogBuffer.add('ID: ${r.device.id}' +
              "\nDevice name: " +
              (r.device.name != "" ? r.device.name : "Unknown") +
              "\n");
        }

        // Write to secure storage
        _storage.write(key: key, value: value);
      }

      // Log scan number
      ongoingLogBuffer.add("Scan number: $_scanNumber Timestamp: " +
          DateTime.fromMillisecondsSinceEpoch(
                  DateTime.now().millisecondsSinceEpoch)
              .toString() +
          '\n');

      // Only log gps when threshold is met and has not been logged yet
      if (ongoingLogBuffer.length > 4 && ran == 0) {
        ran++;
        _logLocation();
      }

      // Update list render
      ongoingLog.insertAll(0, ongoingLogBuffer);

      // Rebuild
      setState(() {
        _counter = results.length;
      });
    });
    
    // Stop any non timed out scan
    bluetoothSingleton.flutterBlueInstance.stopScan();
    ran = 0;
  }

  // TODO: List devices' services (wip)
/* servicesList(ScanResult r) async
  {
   await r.device.connect();
    List<BluetoothService> services = await r.device.discoverServices();

  for(BluetoothService service in services){
    deviceServices.add("+++++++"+   service.uuid.toMac()+ "++++++++++++++");

  }
  print(deviceServices.toString() + " Device: " + r.device.name);
  await r.device.disconnect();
  }*/

// Log the location of the user
  void _logLocation() async {
    
    //initialize location and permissions to be checked
    var location = Location();
    location.changeSettings(accuracy: LocationAccuracy.low);
    PermissionStatus hasPermission;
    bool _serviceEnabled;

    // check if gps service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    //check if permission is granted
    hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      hasPermission = await location.requestPermission();
      if (hasPermission != PermissionStatus.granted) {
        return;
      }
    }
    //once permissions are verified, get location asynchronously
    _currentLocation = await location.getLocation();
    // Find last instance of scan log
    int lastScanIndex = ongoingLog.indexWhere((note) => note.startsWith('Scan'));

    // Add location logging to rendered list
    ongoingLog.insert(
        lastScanIndex + 1,
        " Latitude: " +
            _currentLocation.latitude.toString() +
            " Longitude: " +
            _currentLocation.longitude.toString() +
            "\n");
  }

  // Build the front end display
  @override
  Widget build(BuildContext context) {
    //Start dynamic resizing
    MediaQueryData queryData = MediaQuery.of(context);
    double verticalSafeBlock = (queryData.size.height -
            (queryData.padding.top + queryData.padding.bottom)) /
        100;
    double cardHeight = verticalSafeBlock * 60;
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Logger"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'BT devices around you:',
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headline4,
          ),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: Icon(Icons.bluetooth_searching),
          ),
          Row(
            children: <Widget>[
              buildSlider(context),
              FlatButton(
                child: Text("Scanning duration: " +
                    _cupertinoSliderValue.toInt().toString() +
                    "s"),
                onPressed: () {},
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "IDs and Names",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: Container(
                        height: cardHeight,
                        child: ListView.builder(
                            itemCount: currentScanList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Text(currentScanList[index]);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Scan Log",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: Container(
                        height: cardHeight,
                        child: ListView.builder(
                            itemCount: ongoingLog.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return buildongoingScan(index);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Adds bold text to differentiate between list
  buildongoingScan(int index) {
    // Bold scan numbers
    return (ongoingLog[index].runtimeType == String &&
            (ongoingLog[index].contains("Timestamp:") ||
                ongoingLog[index].contains("Latitude"))
        ? Text(ongoingLog[index], style: TextStyle(fontWeight: FontWeight.bold))
        : Text(ongoingLog[index].toString()));
  }

  // Build slider to set different scan duration
  Widget buildSlider(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSlider(
        //activeColor: Theme.of(context).primaryColor,
        max: 52.0,
        min: 0.0,
        value: _cupertinoSliderValue.toDouble(),
        divisions: 5,
        onChanged: (double newValue) {
          setState(() {
            _cupertinoSliderValue = newValue;
          });
        },
      );
    } else {
      return Slider(
        max: 50.0,
        min: 0.0,
        value: _cupertinoSliderValue.toDouble(),
        divisions: 5,
        onChanged: (double newValue) {
          setState(() {
            _cupertinoSliderValue = newValue;
          });
        },
      );
    }
  }

  // disconnect listeners
  @override
  void dispose() {
    bluetoothSingleton.pauseScan();
    bluetoothSingleton.flutterBlueInstance.stopScan();
    _locationSubscription.cancel();
    subscription.cancel();
    super.dispose();
    bluetoothSingleton.resumeScan(2);
  }
}

// Helper class to log  items
class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}
