import 'package:campus_mobile/core/models/links_model.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';
import 'package:flutter/material.dart';

class LinksList extends StatelessWidget {
  const LinksList({Key key, @required this.data}) : super(key: key);

  final List<LinksModel> data;

  Widget buildList() {
    List<Widget> linksList = List<Widget>();
    for (LinksModel model in data) {
      linksList.add(Text(
        model.name,
      ));
    }
    return Column(
      children: linksList,
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
