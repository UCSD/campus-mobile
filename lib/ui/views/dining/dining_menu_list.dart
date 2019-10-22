import 'package:campus_mobile_beta/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_beta/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/core/services/dining_service.dart';

class DiningMenuList extends StatefulWidget {
  final String id;
  const DiningMenuList({Key key, @required this.id}) : super(key: key);
  @override
  _DiningMenuListState createState() => _DiningMenuListState();
}

class _DiningMenuListState extends State<DiningMenuList> {
  final DiningService _diningService = DiningService();
  Future<DiningMenuItemsModel> _data;

  initState() {
    super.initState();
    _updateData();
  }

  _updateData() {
    if (!_diningService.isLoading) {
      setState(() {
        _data = _diningService.fetchMenu(this.widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DiningMenuItemsModel>(
      future: _data,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Column(
                children: [
                  buildFilterButtons(),
                  buildDiningMenuList(snapshot),
                ],
              )
            : Column();
      },
    );
  }

  Widget buildDiningMenuList(AsyncSnapshot snapshot) {
    DiningMenuItemsModel menu = snapshot.data;
    List<MenuItem> menuList = menu.menuItems;
    List<Widget> list = List<Widget>();
    for (MenuItem item in menuList) {
      list.add(ListTile(
        leading: Text(
          item.name,
          style: TextStyle(color: ColorPrimary),
        ),
        title: Text(item.price),
        onTap: () {
          ///TODO navigate to nutrition page for this item
          Navigator.pushNamed(context, RoutePaths.DiningNutritionView,
              arguments: item);
        },
      ));
    }
    return menuList.isEmpty
        ? Column()
        : Column(
            children: list,
          );
  }

  Widget buildFilterButtons() {
    return Row();
  }
}
