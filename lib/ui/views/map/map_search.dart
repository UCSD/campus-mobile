import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:flutter/material.dart';

class MapSearch extends StatefulWidget {
  final Function test;
  const MapSearch({Key key, this.test}) : super(key: key);
  @override
  _MapSearchState createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  TextEditingController _searchBarController = TextEditingController();

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
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: (text) {
                        //send back text to map.dart
                        widget.test(text);
                        Navigator.pop(context);
                      },
                      autofocus: true,
                      controller: _searchBarController,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: 'Search',
                      ),
                    ),
                  ),
                  _searchBarController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchBarController.clear();
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
                    onPressed: () {},
                  ),
                  LabeledIconButton(
                    icon: Icons.local_drink,
                    text: 'Hydration',
                    onPressed: () {},
                  ),
                  LabeledIconButton(
                    icon: Icons.local_post_office,
                    text: 'Mail',
                    onPressed: () {},
                  ),
                  LabeledIconButton(
                    icon: Icons.local_atm,
                    text: 'ATM',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
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
        Text(
          text,
          //style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
