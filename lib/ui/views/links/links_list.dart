import 'package:campus_mobile_beta/core/models/links_model.dart';
import 'package:campus_mobile_beta/ui/widgets/container_view.dart';
import 'package:campus_mobile_beta/ui/widgets/image_loader.dart';
import 'package:flutter/material.dart';

class LinksList extends StatelessWidget {
  const LinksList({Key key, @required this.data, this.listSize})
      : super(key: key);

  final List<LinksModel> data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return buildLinksList(data, context);
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
        ? Column(
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
      onTap: () {
        //TODO navigate to correct url
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
