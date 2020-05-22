import 'package:campus_mobile_experimental/core/data_providers/links_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/links_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksList extends StatelessWidget {
  const LinksList({Key key, this.listSize}) : super(key: key);
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return Provider.of<LinksDataProvider>(context).isLoading
        ? Center(child: CircularProgressIndicator())
        : buildLinksList(
            Provider.of<LinksDataProvider>(context).linksModels, context);
  }

  Widget buildLinksList(
      List<LinksModel> listOfLinksModels, BuildContext context) {
    final List<Widget> eventTiles = List<Widget>();

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size;
    if (listSize == null)
      size = listOfLinksModels.length;
    else
      size = listSize;
    for (int i = 0; i < size; i++) {
      final LinksModel item = listOfLinksModels[i];
      final tile = buildLinkTile(item, context);
      eventTiles.add(tile);
    }

    return listSize != null
        ? ListView(
            primary: false,
            shrinkWrap: true,
            children: ListTile.divideTiles(tiles: eventTiles, context: context)
                .toList(),
          )
        : ContainerView(
            child: ListView(
              children:
                  ListTile.divideTiles(tiles: eventTiles, context: context)
                      .toList(),
            ),
          );
  }

  Widget buildLinkTile(LinksModel data, BuildContext context) {
    return ListTile(
      onTap: () async {
        if (await canLaunch(data.url)) {
          await launch(data.url);
        } else {
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Could not open URL.'),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      leading: Icon(data.icon),
      title: Text(
        data.name,
        textAlign: TextAlign.start,
      ),
      trailing: Icon(Icons.arrow_right),
    );
  }
}
