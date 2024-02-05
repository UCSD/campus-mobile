import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_IAmGoing.dart';
import 'package:campus_mobile_experimental/ui/profile/notification_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigator/bottom.dart';

bool hideListView = false; // debug
List<String> eventTypesForIAmGoing = [
  "campusInnovationEvents",
  "freeFood",
  "testCampusInnovationEvents",
  "testFreeFood",
]; // for the "I am Going" feature

class NotificationsListView extends StatefulWidget {
  @override
  State<NotificationsListView> createState() => _NotificationsListViewState();
}

class _NotificationsListViewState extends State<NotificationsListView> {
  @override
  initState() {
    super.initState();
    hideListView = true;
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      notificationScrollController.jumpTo(getNotificationsScrollOffset());
      setState(() {
        hideListView = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
    return Offstage(
      offstage: hideListView,
      child: RefreshIndicator(
        child: buildListView(context),
        onRefresh: () {
          return Provider.of<MessagesDataProvider>(context, listen: false)
              .fetchMessages(true);
        },
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    Widget Function(BuildContext context, int index)? itemBuilder;
    int itemCount = 0;
    if (Provider.of<MessagesDataProvider>(context).messages!.length == 0) {
      if (Provider.of<MessagesDataProvider>(context).error == null) {
        if (Provider.of<MessagesDataProvider>(context).isLoading!) {
          // empty notifications view until they load in
        } else {
          itemBuilder =
              (BuildContext context, int index) => _buildNoMessagesText();
          itemCount = 1;
        }
      } else {
        itemBuilder = (BuildContext context, int index) => _buildErrorText();
        itemCount = 1;
      }
    }
    if (itemCount == 0) {
      itemBuilder = _buildMessage;
      itemCount = Provider.of<MessagesDataProvider>(context).messages!.length;
    }
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: itemBuilder!,
      controller: notificationScrollController,
      itemCount: itemCount,
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  Widget _buildErrorText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(NotificationsConstants.statusFetchProblem),
      ],
    );
  }

  Widget _buildNoMessagesText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            NotificationsConstants.statusNoMessages,
          ),
        ),
      ],
    );
  }

  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    late StreamSubscription _sub;
    _sub = linkStream.listen((String? link) async {
      // handling for map query
      if (link!.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query']!;
        // redirect query to maps tab and search with query
        Provider.of<MapsDataProvider>(context, listen: false)
            .searchBarController
            .text = query;
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
        Provider.of<BottomNavigationBarProvider>(context, listen: false)
            .currentIndex = NavigatorConstants.MapTab;
        // received deeplink, cancel stream to prevent memory leaks
        _sub.cancel();
      }
    });
  }

  Widget _buildMessage(BuildContext context, int index) {
    MessageElement data =
        Provider.of<MessagesDataProvider>(context).messages![index]!;

    String? messageType;
    if (data.audience!.topics == null) {
      messageType = "DM";
    } else {
      messageType = data.audience?.topics![0];
    }
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        ListTile(
            leading: Icon(chooseIcon(messageType!),
                color: Theme.of(context).colorScheme.secondary, size: 30),
            title: Column(
              children: <Widget>[
                Text(
                  data.message!.title!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(padding: const EdgeInsets.all(3.5))
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            subtitle: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Linkify(
                    text: data.message!.message!,
                    onOpen: (link) async {
                      try {
                        await launch(link.url, forceSafariVC: true);
                      } catch (e) {
                        // an error occurred, do nothing
                      }
                    },
                    options: LinkifyOptions(humanize: false),
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
            trailing: Column(children: <Widget>[
              Text(_readTimestamp(data.timestamp!),
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ])),
        // check if the event type needs the "I am going" feature (e.g., "freeFood" events),
        // if true, use IAmGoingNotification format
        // if false, use regular notification format
        needIAmGoingFeature(data.messageId, messageType, eventTypesForIAmGoing)
            ? IAmGoingNotification(data: data)
            : Container(),
      ],
    );
  }

  // this function checks whether the current notification's messageType requires the "I am Going" feature
  // this currently only apply to "campusInnovationEvents" and "freeFood" notifications
  // a list of event types for "I am Going" feature is defined the eventTypesForIAmGoing variable
  bool needIAmGoingFeature(
      String? messageId, String? messageType, List<String> eventTypes) {
    // print('messageType is: $messageType');
    return eventTypes.contains(messageType);
  }

  String _readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds < 60) {
      time = 'JUST NOW';
    } else if (diff.inMinutes < 60) {
      if (diff.inMinutes.floor() == 1) {
        time = diff.inMinutes.toString() + ' MIN';
      } else {
        time = diff.inMinutes.toString() + ' MINS';
      }
    } else if (diff.inHours < 24) {
      if (diff.inHours.floor() == 1) {
        time = diff.inHours.toString() + ' HR';
      } else {
        time = diff.inHours.toString() + ' HRS';
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' D';
      } else {
        time = diff.inDays.toString() + ' D';
      }
    } else if (diff.inDays >= 7 && diff.inDays < 365) {
      if (diff.inDays.floor() == 7) {
        time = (diff.inDays / 7).floor().toString() + ' W';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' W';
      }
    } else {
      time = ((diff.inDays / 7).floor() / 52).floor().toString() + ' Y';
    }
    return time;
  }
}
