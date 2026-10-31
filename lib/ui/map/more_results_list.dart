import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreResultsList extends StatelessWidget {
  const MoreResultsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
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
                    child: Text('More Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Divider(height: 0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Provider.of<MapsDataProvider>(context).mapSearchModels.length,
                      itemBuilder: (BuildContext cntxt, int index) {
                        return ListTile(
                          title: Text(
                            Provider.of<MapsDataProvider>(cntxt, listen: false).mapSearchModels[index].title!,
                          ),
                          trailing: Text(
                            Provider.of<MapsDataProvider>(cntxt, listen: false).mapSearchModels[index].distance != null
                                ? Provider.of<MapsDataProvider>(
                                        cntxt,
                                        listen: false,
                                      ).mapSearchModels[index].distance!.toStringAsFixed(1) +
                                      ' mi'
                                : '--',
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                          onTap: () {
                            Provider.of<MapsDataProvider>(cntxt, listen: false).addMarker(index);
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
            backgroundColor: actionButtonBackgroundColor,
            padding: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('SHOW MORE RESULTS', style: TextStyle(color: lightPrimaryColor, fontSize: 16)),
        ),
      ),
    );
  }
}
