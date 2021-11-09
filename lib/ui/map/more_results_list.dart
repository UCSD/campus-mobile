import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreResultsList extends StatelessWidget {
  const MoreResultsList({
    Key? key,
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
                    itemCount: Provider.of<MapsDataProvider>(context)
                        .mapSearchModels
                        .length,
                    itemBuilder: (BuildContext cntxt, int index) {
                      return ListTile(
                        title: Text(
                          Provider.of<MapsDataProvider>(cntxt, listen: false)
                              .mapSearchModels[index]
                              .title!,
                        ),
                        trailing: Text(
                          Provider.of<MapsDataProvider>(cntxt, listen: false)
                                      .mapSearchModels[index]
                                      .distance !=
                                  null
                              ? Provider.of<MapsDataProvider>(cntxt,
                                          listen: false)
                                      .mapSearchModels[index]
                                      .distance!
                                      .toStringAsFixed(1) +
                                  ' mi'
                              : '--',
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                        onTap: () {
                          Provider.of<MapsDataProvider>(cntxt, listen: false)
                              .addMarker(index);
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
          primary: Theme.of(context).buttonColor,
        ),
        child: Text(
          'Show More Results',
          style: TextStyle(color: Theme.of(context).textTheme.button!.color),
        ),
      ),
    );
  }
}
