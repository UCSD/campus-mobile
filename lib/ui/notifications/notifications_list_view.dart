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
    );
  }

  Widget buildListView(BuildContext context) {
    if (Provider.of<MessagesDataProvider>(context).messages.length == 0) {
      if (Provider.of<MessagesDataProvider>(context).error == null) {
        if (Provider.of<MessagesDataProvider>(context).isLoading) {
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
      itemCount: Provider.of<MessagesDataProvider>(context).messages.length,
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

  StreamSubscription _sub;

  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    _sub = linkStream.listen((String link) async {
      // handling for map query
      if (link.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query'];
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
        Provider.of<MessagesDataProvider>(context).messages[index];
    FreeFoodDataProvider freefoodProvider =
        Provider.of<FreeFoodDataProvider>(context);

    return ListTile(
      leading: Icon(Icons.info, color: Colors.grey, size: 30),
      title: Column(
        children: <Widget>[
          Text(_readTimestamp(data.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          Text(data.message.title),
          Padding(padding: const EdgeInsets.all(3.5))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      subtitle: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Linkify(
              text: data.message.message,
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
    );
  }

  String _readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds < 60) {
      time = 'A FEW MOMENTS AGO';
    } else if (diff.inMinutes < 60) {
      if (diff.inMinutes.floor() == 1) {
        time = diff.inMinutes.toString() + ' MINUTE AGO';
      } else {
        time = diff.inMinutes.toString() + ' MINUTES AGO';
      }
    } else if (diff.inHours < 24) {
      if (diff.inHours.floor() == 1) {
        time = diff.inHours.toString() + ' HOUR AGO';
      } else {
        time = diff.inHours.toString() + ' HOURS AGO';
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else if (diff.inDays >= 7 && diff.inDays < 365) {
      if (diff.inDays.floor() == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    } else {
      time = ((diff.inDays / 7).floor() / 52).floor().toString() + ' YEAR AGO';
    }
    return time;
  }
}
