import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/core/models/links_model.dart';
import 'package:campus_mobile_beta/core/services/links_service.dart';
import 'package:campus_mobile_beta/ui/views/links/links_list.dart';
import 'package:campus_mobile_beta/ui/widgets/cards/card_container.dart';
import 'package:flutter/material.dart';

class LinksCard extends StatefulWidget {
  @override
  _LinksCardState createState() => _LinksCardState();
}

class _LinksCardState extends State<LinksCard> {
  final LinksService _linksService = LinksService();
  Future<List<LinksModel>> _data;

  initState() {
    super.initState();
    _updateData();
  }

  void _updateData() {
    if (!_linksService.isLoading) {
      setState(() {
        _data = _linksService.fetchData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LinksModel>>(
      future: _data,
      builder: (context, snapshot) {
        return CardContainer(
          title: Text('Links'),
          isLoading: false,
          reload: () => print('reloading'),
          errorText: null,
          child: buildLinksCard(snapshot),
          hidden: false,
          overFlowMenu: {'print hi': () => print('hi')},
          actionButtons: buildActionButtons(snapshot.data),
        );
      },
    );
  }

  Widget buildLinksCard(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return LinksList(
        data: snapshot.data,
        listSize: 4,
      );
    } else {
      return Container();
    }
  }

  List<Widget> buildActionButtons(List<LinksModel> data) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.LinksViewAll, arguments: data);
      },
    ));
    return actionButtons;
  }
}
