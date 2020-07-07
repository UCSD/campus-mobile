import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';

class BluetoothLoggerView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BluetoothLoggerViewState();
}

class _BluetoothLoggerViewState extends State<BluetoothLoggerView> {
  final _storage = FlutterSecureStorage();
  List<_SecItem> _items = [];
  int _counter = 0;
  int _scanNumber = 0;
  List<Widget> list = List<Widget>();
  double _cupertinoSliderValue = 2.0;

  static Map<String, String> allValues = {};
  static List secondList = [];
  static List thirdList = [];
  static List toAdd = [];
 // static List deviceServices = [];
  StreamSubscription<LocationData> _locationSubscription;
  LocationData _currentLocation;
  var _locationService = new Location();

  @override
  void initState() {
    super.initState();
    _locationSubscription = _locationService
        .onLocationChanged()
        .listen((LocationData currentLocation) async {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

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

  void _incrementCounter() {
    _readAll();

    FlutterBlue flutterBlue = FlutterBlue.instance;

    // Instances to keep track of scan # and current run
    _scanNumber++;
    int ran = 0;

    flutterBlue.startScan(
        timeout: Duration(
            seconds: (_cupertinoSliderValue.toInt() == 2
                ? 2
                : _cupertinoSliderValue.toInt())),
        allowDuplicates: false);
    toAdd.clear();
    flutterBlue.scanResults.listen((results) async {

      //Reset rendering lists as necessary
      secondList.clear();
      for (int i = 0; i < toAdd.length; i++) {
        thirdList.removeAt(0);
      }
      toAdd.clear();


      for (ScanResult r in results) {
        final String key = _randomValue();
        final String value = r.device.id.toString();

        // Add to current scan log
        if (!secondList.contains('ID: ${r.device.id}' +
            "\nDevice name: " +
            (r.device.name != "" ? r.device.name : "Unknown") +
            "\n")) {
          secondList.add('ID: ${r.device.id}' +
              "\nDevice name: " +
              (r.device.name != "" ? r.device.name : "Unknown") +
              "\n");
        }

        // Add to device log
        if (!toAdd.contains('ID: ${r.device.id}' +
            "\nDevice name: " +
            (r.device.name != "" ? r.device.name : "Unknown") +
            "\n")) {
          toAdd.add('ID: ${r.device.id}' +
              "\nDevice name: " +
              (r.device.name != "" ? r.device.name : "Unknown") +
              "\n");
        }

        _storage.write(key: key, value: value);
       // _storage.deleteAll(); ENABLE FOR FASTER SCAN
      }

      // Log scan number
      toAdd.add("Scan number: $_scanNumber Timestamp: " +
          DateTime.fromMillisecondsSinceEpoch(
                  DateTime.now().millisecondsSinceEpoch)
              .toString() +
          '\n');

      // Only log gps when threshold is met and has not been logged yet
      if (toAdd.length > 4 && ran == 0) {
        ran++;
        _logLocation();
        toAdd.add("value");
      }

      // Update list render
      thirdList.insertAll(0, toAdd);

      // Rebuild
      setState(() {
        _counter = results.length;
      });
    });

    ran = 0;}

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

  void _logLocation() async {

    // Instantiate location services
    var location = Location();
    location.changeSettings(accuracy: LocationAccuracy.LOW);
    LocationData position;

    // Check Permissions
    bool hasPermission = await location.hasPermission() && await location.serviceEnabled();
    if (Platform.isAndroid) {
      if (!hasPermission) {
        hasPermission = await location.requestPermission() &&
            await location.requestService();
      }
    }
    if (hasPermission) {
      position = await location
          .getLocation()
          .catchError((e) => print("Unable to find your position."),
              test: (e) => e is PlatformException)
          .catchError((e) => print("$e"));
    }

    // Find last instance of scan log
    int lastScanIndex = thirdList.indexWhere((note) => note.startsWith('Scan'));

    // Add location logging to rendered list
    thirdList.insert(
        lastScanIndex + 1,
        " Latitude: " +
            position.latitude.toString() +
            " Longitude: " +
            position.longitude.toString() +
            "\n");
   /* print(" Latitude: " +
        position.latitude.toString() +
        " Longitude: " +
        position.longitude.toString() +
        "\n"); DEBUG STATEMENT*/
    //print(thirdList.toString()); DEBUG STATEMENT
  }


  @override
  Widget build(BuildContext context) {
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
                        height: 500,
                        child: ListView.builder(
                            itemCount: secondList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Text(secondList[index]);
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
                        height: 500,
                        child: ListView.builder(
                            itemCount: thirdList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return buildThirdList(index);
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

  buildThirdList(int index) {

    // Bold scan numbers
    return (thirdList[index].runtimeType == String &&
            (thirdList[index].contains("Timestamp:") ||
                thirdList[index].contains("Latitude"))
        ? Text(thirdList[index], style: TextStyle(fontWeight: FontWeight.bold))
        : Text(thirdList[index].toString()));
  }

  Widget fillList() {
    allValues.forEach((key, value) {
      list.add(SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) => writeBluetoothDevice(key, value)),
      ));
    });

    return CustomScrollView(
      slivers: list,
      shrinkWrap: true,
    );
  }

  Widget buildSlider(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSlider(
        //activeColor: Theme.of(context).primaryColor,
        max: 200.0,
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
        max: 200.0,
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
}

Widget writeBluetoothDevice(String key, String value) {
  return Text(value);
}

class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}
