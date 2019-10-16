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

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildList(),
    );
  }
}