import 'package:campus_mobile_experimental/core/data_providers/maps_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapSearch extends StatefulWidget {
  @override
  _MapSearchState createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        children: <Widget>[
          Hero(
            tag: 'search_bar',
            child: Card(
              margin: EdgeInsets.all(5),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    alignment: Alignment.centerLeft,
                    iconSize: 30,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (text) {
                        setState(
                            () {}); // Sets state so that the X on the right will show up
                      },
                      onSubmitted: (text) {
                        if (Provider.of<MapsDataProvider>(context,
                                listen: false)
                            .searchBarController
                            .text
                            .isNotEmpty) {
                          // Don't fetch on empty text field
                          Provider.of<MapsDataProvider>(context, listen: false)
                              .fetchLocations(); // Text doesn't need to be sent over because it's already in the controller
                        }
                        Navigator.pop(context);
                      },
                      autofocus: true,
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
                  Provider.of<MapsDataProvider>(context)
                          .searchBarController
                          .text
                          .isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Provider.of<MapsDataProvider>(context,
                                    listen: false)
                                .searchBarController
                                .clear();
                            Provider.of<MapsDataProvider>(context,
                                    listen: false)
                                .markers
                                .clear();
                            setState(() {});
                          },
                        )
                      : Container(height: 0)
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  LabeledIconButton(
                    icon: Icons.local_parking,
                    text: 'Parking',
                    onPressed: () {
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .searchBarController
                          .text = 'Parking';
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .fetchLocations();
                      Navigator.pop(context);
                    },
                  ),
                  LabeledIconButton(
                    icon: Icons.local_drink,
                    text: 'Hydration',
                    onPressed: () {
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .searchBarController
                          .text = 'Hydration';
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .fetchLocations();
                      Navigator.pop(context);
                    },
                  ),
                  LabeledIconButton(
                    icon: Icons.local_post_office,
                    text: 'Mail',
                    onPressed: () {
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .searchBarController
                          .text = 'Mail';
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .fetchLocations();
                      Navigator.pop(context);
                    },
                  ),
                  LabeledIconButton(
                    icon: Icons.local_atm,
                    text: 'ATM',
                    onPressed: () {
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .searchBarController
                          .text = 'ATM';
                      Provider.of<MapsDataProvider>(context, listen: false)
                          .fetchLocations();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          Provider.of<MapsDataProvider>(context).searchHistory.isEmpty
              ? Card(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: Text('You have no recent searches')),
                  ),
                )
              : Flexible(
                  child: Card(
                    margin: EdgeInsets.all(5),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(height: 0),
                      itemCount: Provider.of<MapsDataProvider>(context)
                          .searchHistory
                          .length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          leading: Icon(Icons.history),
                          title: Text(Provider.of<MapsDataProvider>(context)
                              .searchHistory
                              .reversed
                              .toList()[index]),
                          trailing: IconButton(
                            iconSize: 20,
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              Provider.of<MapsDataProvider>(context,
                                      listen: false)
                                  .removeFromSearchHistory(
                                      Provider.of<MapsDataProvider>(context,
                                              listen: false)
                                          .searchHistory
                                          .reversed
                                          .toList()[index]);
                            },
                          ),
                          onTap: () {
                            Provider.of<MapsDataProvider>(context,
                                    listen: false)
                                .searchBarController
                                .text = Provider.of<MapsDataProvider>(context,
                                    listen: false)
                                .searchHistory
                                .reversed
                                .toList()[index];
                            Provider.of<MapsDataProvider>(context,
                                    listen: false)
                                .fetchLocations();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

class LabeledIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onPressed;
  LabeledIconButton({this.icon, this.text, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          onPressed: onPressed,
          shape: CircleBorder(),
          color: Colors.red,
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(text),
      ],
    );
  }
}
