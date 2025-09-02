import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_styles.dart';
import '../common/container_view.dart';

class DiningFilterView extends StatelessWidget {
  DiningFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerView(child: buildSettingsList(context, payment_options));
  }

  Widget buildSettingsList(BuildContext context, List<String> topicsData) {
    return (Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: createList(context, topicsData),
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ).toList(),
      ),
    ));
  }

  final payment_options = [
    "Card",
    "Visa",
    "MaterCard",
    "American Express",
    "Dining Dollars",
    "Triton Cash",
    "Dept Recharge",
    "Community Dining"
  ];

  List<Widget> createList(BuildContext context, List<String> topicsAvailable) {
    List<Widget> list = [];
    for (String topic in topicsAvailable) {
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            key: Key(topic),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                topic,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch.adaptive(
                value: true,
                onChanged: (value) {},
                activeColor: toggleActiveColor,
              ),
            ),
          ),
        ),
      );
    }
    return list;
  }
}
