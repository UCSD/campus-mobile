import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';

class MapSearch extends StatefulWidget {
  final Function queryInput;
  const MapSearch({Key key, this.queryInput}) : super(key: key);
  @override
  _MapSearchState createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  TextEditingController _searchBarController = TextEditingController();
  List<String> recentSearches = [];

  /*
  IMPORTANT NOTE: Search history still needs to be hooked up so it can
  be conserved over navigation and app restarts.
  TODO: Hook up search history [recentSearches] to Provider (when implemented)
  */

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
                        recentSearches.add(text);
                        widget.queryInput(text, _searchBarController);
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
                    onPressed: () {
                      _searchBarController.text = 'Parking';
                      recentSearches.add('Parking');
                      widget.queryInput('Parking', _searchBarController);
                      Navigator.pop(context);
                    },
                  ),
                  LabeledIconButton(
                    icon: Icons.local_drink,
                    text: 'Hydration',
                    onPressed: () {
                      _searchBarController.text = 'Hydration';
                      recentSearches.add('Hydration');
                      widget.queryInput('Hydration', _searchBarController);
                      Navigator.pop(context);
                    },
                  ),
                  LabeledIconButton(
                    icon: Icons.local_post_office,
                    text: 'Mail',
                    onPressed: () {
                      _searchBarController.text = 'Mail';
                      recentSearches.add('Mail');
                      widget.queryInput('Mail', _searchBarController);
                      Navigator.pop(context);
                    },
                  ),
                  LabeledIconButton(
                    icon: Icons.local_atm,
                    text: 'ATM',
                    onPressed: () {
                      _searchBarController.text = 'ATM';
                      recentSearches.add('ATM');
                      widget.queryInput('ATM', _searchBarController);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
              margin: EdgeInsets.all(5),
              child: recentSearches.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      child: Center(child: Text('You have no recent searches')),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(height: 0),
                      itemCount: recentSearches.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          leading: Icon(Icons.history),
                          title: Text(recentSearches[index]),
                          trailing: IconButton(
                            iconSize: 20,
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                recentSearches.remove(recentSearches[index]);
                              });
                            },
                          ),
                          onTap: () {
                            _searchBarController.text = recentSearches[index];
                            widget.queryInput(
                                recentSearches[index], _searchBarController);
                            Navigator.pop(context);
                          },
                        );
                      },
                    )),
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
