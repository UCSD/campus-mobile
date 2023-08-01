import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/notifications_freefood.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_freefood.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
    return RefreshIndicator(
      child: buildListView(context),
      onRefresh: () => Provider.of<MessagesDataProvider>(context, listen: false)
          .fetchMessages(true),
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget buildListView(BuildContext context) {
    if (Provider.of<MessagesDataProvider>(context).messages!.length == 0) {
      if (Provider.of<MessagesDataProvider>(context).error == null) {
        if (Provider.of<MessagesDataProvider>(context).isLoading!) {
          // empty notifications view until they load in
        } else {
          return ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) =>
                _buildNoMessagesText(),
            controller:
                Provider.of<MessagesDataProvider>(context).scrollController,
            itemCount: 1,
            separatorBuilder: (BuildContext context, int index) => Divider(),
          );
        }
      } else {
        return ListView.separated(
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) => _buildErrorText(),
          controller:
              Provider.of<MessagesDataProvider>(context).scrollController,
          itemCount: 1,
          separatorBuilder: (BuildContext context, int index) => Divider(),
        );
      }
    }
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: _buildMessage,
      controller: Provider.of<MessagesDataProvider>(context).scrollController,
      itemCount: Provider.of<MessagesDataProvider>(context).messages!.length,
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
    FreeFoodDataProvider freefoodProvider =
        Provider.of<FreeFoodDataProvider>(context);

    String? messageType;
    if(data.audience!.topics == null)  {
      messageType = "DM";
    }
    else {
      messageType = data.audience?.topics![0];
    }


    return ListTile(
      leading: Icon(_chooseIcon(messageType!), color: Theme.of(context).colorScheme.secondary, size: 30),
      title: Column(
        children: <Widget>[
          Text(data.message!.title!, style: TextStyle(fontWeight: FontWeight.bold),),
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
          freefoodProvider.isFreeFood(data.messageId)
              ? FreeFoodNotification(messageId: data.messageId)
              : Container(),
        ],
      ),
        trailing: Column(
          children: <Widget>[
            Text(_readTimestamp(data.timestamp!),
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ]
      )
    );
  }

  IconData _chooseIcon(String messageType) {
    if (messageType == "studentAnnouncements" || messageType == "testStudentAnnouncements") {
      return Icons.school_outlined;
    }
    else if (messageType == "freeFood") {
      return Icons.restaurant_outlined;
    }
    else if (messageType == "campusAnnouncements" || messageType == "testCampusAnnouncements") {
        return Icons.campaign_outlined;
    }
    else if (messageType == "DM"){
      return Icons.info_outline;
    }
    return Icons.info_outline;
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
