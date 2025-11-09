import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageShuttleView extends StatefulWidget {
  _ManageShuttleViewState createState() => _ManageShuttleViewState();
}

class _ManageShuttleViewState extends State<ManageShuttleView> {
  /// PROVIDERS
  late ShuttleDataProvider _shuttleDataProvider;

  @override
  Widget build(BuildContext context) {
    _shuttleDataProvider = Provider.of<ShuttleDataProvider>(context);
    return Stack(children: <Widget>[
      ContainerView(
        child: buildLocationsList(context),
      ),
      buildAddStopsButton(context),
    ]);
  }

  Widget buildLocationsList(BuildContext context) {
    if (_shuttleDataProvider.stopsToRender.isEmpty) {
      return (Center(child: Text("No saved stops.")));
    } else {
      return ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text("Hold and drag to reorder",
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ),
        children: createList(context),
        onReorder: _onReorder,
      );
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    List<ShuttleStopModel?> newOrder = _shuttleDataProvider.stopsToRender;
    List<ShuttleStopModel> toRemove = [];

    newOrder.removeWhere((element) => toRemove.contains(element));
    ShuttleStopModel? item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    List<int?> orderedStopNames = [];
    for (ShuttleStopModel? item in newOrder) {
      orderedStopNames.add(item!.id);
    }
    _shuttleDataProvider.reorderStops(orderedStopNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (ShuttleStopModel? model in _shuttleDataProvider.stopsToRender) {
      if (model != null) {
        list.add(Card(
          key: Key(model.id.toString()),
          elevation: 2.0,
          margin: EdgeInsets.fromLTRB(cardMargin, 5, cardMargin, 5),
          child: ListTile(
              title: Text(model.name, style: Theme.of(context).textTheme.bodyMedium),
              leading: Icon(Icons.drag_handle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? linkTextColorDark
                      : linkTextColorLight),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    await _shuttleDataProvider.removeStop(model.id);
                  })),
        ));
      }
    }
    return list;
  }

  Widget buildAddStopsButton(BuildContext context) {
    return Positioned(
      bottom: 50.0,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ActionButton(
          buttonText: 'ADD MORE STOPS',
          onPressed: () {
            if (_shuttleDataProvider.stopsToRender.length < 5) {
              Navigator.pushNamed(context, RoutePaths.AddShuttleStopsView);
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialogWidget(
                      type: MessageTypeConstants.ERROR,
                      icon: Icons.block_flipped,
                      title: LoginConstants.shuttleMaxTitle,
                      description: LoginConstants.shuttleMaxDesc,
                      onClose: () {
                        Navigator.of(context).pop();
                      },
                    );
                  });
            }
          },
        ),
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.only(right: 20.0, bottom: 40.0),
    //   child: Align(
    //     alignment: Alignment.bottomRight,
    //     child: FloatingActionButton(
    //       child: Icon(
    //         Icons.add,
    //         color: Colors.white,
    //       ),
    //       backgroundColor: ColorPrimary,
    //       onPressed: () {
    //         if (_shuttleDataProvider.stopsToRender.length < 5) {
    //           Navigator.pushNamed(context, RoutePaths.AddShuttleStopsView);
    //         } else {
    //           showAlertDialog(context);
    //         }
    //       },
    //     ),
    //   ),
    // );
  }

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(5, 5, 0, 0),
      contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 20),
      backgroundColor: systemErrorBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF00629B)),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Icon(Icons.block,
                color: Theme.of(context).brightness == Brightness.dark
                    ? systemErrorTextColorDark
                    : systemErrorTextColorLight),
            flex: 1,
          ),
          Expanded(
            child: Text(
              LoginConstants.shuttleMaxTitle,
              textAlign: TextAlign.left,
              style: Theme.of(context).brightness == Brightness.dark
                  ? TextStyle(
                      color: systemErrorTextColorDark,
                      fontFamily: 'Brix Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0)
                  : TextStyle(
                      color: systemErrorTextColorLight,
                      fontFamily: 'Brix Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0),
            ),
            flex: 6,
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? systemErrorTextColorDark
                      : systemErrorTextColorLight),
              alignment: Alignment.topRight,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            flex: 2,
          ),
        ],
      ),
      content: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.6, // Set max height to 60% of screen height
        ),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LoginConstants.shuttleMaxDesc,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).brightness == Brightness.dark
                          ? TextStyle(
                              color: systemErrorTextColorDark,
                              fontFamily: 'Brix Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0)
                          : TextStyle(
                              color: systemErrorTextColorLight,
                              fontFamily: 'Brix Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              bottom: 5.0, // Move up by 50px
              left: 0,
              right: 0,
              child: alert,
            ),
          ],
        );
      },
    );
  }
}
