import 'package:campus_mobile_experimental/core/models/surf_model.dart';
import 'package:campus_mobile_experimental/core/services/surf_service.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/widgets/image_loader.dart';
import 'package:flutter/material.dart';

class SurfView extends StatefulWidget {
  @override
  _SurfViewModel createState() => _SurfViewModel();
}

class _SurfViewModel extends State<SurfView> {
  final SurfService _surfService = SurfService();
  Future<SurfModel> _data;
  @override
  void initState() {
    _updateData();
    super.initState();
  }

  _updateData() {
    if (!_surfService.isLoading) {
      setState(() {
        _data = _surfService.fetchData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        return ContainerView(
            child: snapshot.hasData
                ? surfReport(snapshot.data, context)
                : CircularProgressIndicator());
      },
    );
  }

  Widget surfReport(SurfModel data, BuildContext context) {
    return ListView(
      children: <Widget>[
        ImageLoader(
          url:
              'https://raw.githubusercontent.com/UCSD/campus-mobile/master/app/assets/images/surf_report_header.jpg',
          fullSize: true,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Text(
            'Surf Report for ${getDate()}',
            style: TextStyle(fontSize: 30, color: Colors.blue[700]),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Text(
            data.forecast,
            style: TextStyle(fontSize: 20),
          ),
        ),
        Column(
          children: makeAllSpotsForecast(data, context),
        ),
      ],
    );
  }

  List<Widget> makeAllSpotsForecast(SurfModel data, BuildContext context) {
    List<Widget> list = List<Widget>();
    for (int i = 0; i < data.spots.length; i++) {
      list.add(oneSpot(data, i));
    }
    return ListTile.divideTiles(tiles: list, context: context).toList();
  }

  Widget oneSpot(SurfModel data, int spotNum) {
    return ListTile(
      title: Text(
        data.spots[spotNum].title,
        style: TextStyle(fontSize: 27),
      ),
      subtitle: Text(
        'Surf Height: ${data.spots[spotNum].surfMin}-${data.spots[spotNum].surfMax}ft',
        style: TextStyle(fontSize: 22),
      ),
    );
  }

  String getDate() {
    int day = DateTime.now().weekday;
    String namedDay;
    switch (day) {
      case 0:
        namedDay = 'Sunday';
        break;
      case 1:
        namedDay = 'Monday';
        break;
      case 2:
        namedDay = 'Tuesday';
        break;
      case 3:
        namedDay = 'Wednesday';
        break;
      case 4:
        namedDay = 'Thursday';
        break;
      case 5:
        namedDay = 'Friday';
        break;
      case 6:
        namedDay = 'Saturday';
        break;
    }
    int month = DateTime.now().month;
    String namedMonth;
    switch (month) {
      case 1:
        namedMonth = 'January';
        break;
      case 2:
        namedMonth = 'February';
        break;
      case 3:
        namedMonth = 'March';
        break;
      case 4:
        namedMonth = 'April';
        break;
      case 5:
        namedMonth = 'May';
        break;
      case 6:
        namedMonth = 'June';
        break;
      case 7:
        namedMonth = 'July';
        break;
      case 8:
        namedMonth = 'August';
        break;
      case 9:
        namedMonth = 'September';
        break;
      case 10:
        namedMonth = 'October';
        break;
      case 11:
        namedMonth = 'November';
        break;
      case 12:
        namedMonth = 'December';
        break;
    }
    return '$namedDay, $namedMonth ${DateTime.now().day}';
  }
}
