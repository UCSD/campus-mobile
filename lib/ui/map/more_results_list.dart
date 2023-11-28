import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreResultsList extends StatelessWidget {
  final List<MapSearchModel> mapSearchModels;
  final void Function(int index) addMarker;

  const MoreResultsList({
    Key? key,
    required this.mapSearchModels,
    required this.addMarker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              children: <Widget>[
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    'More Results',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  height: 0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mapSearchModels.length,
                    itemBuilder: (BuildContext cntxt, int index) {
                      return ListTile(
                        title: Text(
                          mapSearchModels[index].title!,
                        ),
                        trailing: Text(
                          mapSearchModels[index].distance != null
                              ? mapSearchModels[index]
                                      .distance!
                                      .toStringAsFixed(1) +
                                  ' mi'
                              : '--',
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                        onTap: () {
                          addMarker(index);
                          Navigator.pop(cntxt);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          // primary: Theme.of(context).buttonColor,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        child: Text(
          'Show More Results',
          style: TextStyle(color: Theme.of(context).textTheme.button!.color),
        ),
      ),
    );
  }
}
