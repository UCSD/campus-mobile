import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/notifications_freefood.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_freefood.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigator/bottom.dart';

/// TODO: make this not global. Probably put into Widget as stateful variable...
var hideListView = false;

class NotificationsListView extends StatefulWidget {
  @override
  State<NotificationsListView> createState() => _NotificationsListViewState();
}

class _NotificationsListViewState extends State<NotificationsListView> {
  @override
  void initState() {
    super.initState();
    hideListView = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessagesDataProvider>(context, listen: false)
          .notificationScrollController
          .jumpTo(getNotificationsScrollOffset());
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
    /// TODO: fix this logic up
    Widget Function(BuildContext context, int index)? itemBuilder;
    var itemCount = 0;
    if (Provider.of<MessagesDataProvider>(context).messages.length == 0) {
      if (Provider.of<MessagesDataProvider>(context).error == null) {
        if (Provider.of<MessagesDataProvider>(context).isLoading) {
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
      itemBuilder =
          (BuildContext context, int index) => _buildMessage(context, index);
      itemCount = Provider.of<MessagesDataProvider>(context).messages.length;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        padding: EdgeInsets.only(top: 8),
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: itemBuilder!,
        controller: Provider.of<MessagesDataProvider>(context, listen: false)
            .notificationScrollController,
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) => Divider(
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ),
      ),
    );
  }

  static Widget _buildErrorText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(NotificationsConstants.statusFetchProblem),
      ],
    );
  }

  static Widget _buildNoMessagesText() {
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
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations(false);
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

    String messageType = data.audience.topics?[0] ?? "DM";
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        ListTile(
          minTileHeight: 20,
          titleAlignment: ListTileTitleAlignment.top,
          minVerticalPadding: 0,
          minLeadingWidth: 10,
          contentPadding: EdgeInsets.all(0),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(NotificationsFilterView.chooseIcons(messageType),
                  color: Theme.of(context).iconTheme.color, size: 30),
            ],
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(data.message.title,
                    style: Theme.of(context).brightness == Brightness.dark
                        ? headlineMediumDark2
                        : headlineMediumLight2),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Linkify(
                    text: data.message.message,
                    onOpen: (link) async {
                      try {
                        await launch(link.url, forceSafariVC: true);
                      } catch (e) {
                        // an error occurred, do nothing
                      }
                    },
                    options: LinkifyOptions(humanize: false),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 16,
                        height: 1.41,
                        fontWeight: FontWeight.w400)),
                freefoodProvider.isFreeFood(data.messageId)
                    ? FreeFoodNotification(messageId: data.messageId)
                    : Container(),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(_readTimestamp(data.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.41,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds < 60) {
      time = 'JUST NOW';
    } else if (diff.inMinutes < 60) {
      time = '${diff.inMinutes} ${diff.inMinutes == 1 ? 'MIN' : 'MINS'}';
    } else if (diff.inHours < 24) {
      time = '${diff.inHours} ${diff.inHours == 1 ? 'HR' : 'HRS'}';
    } else if (diff.inDays < 7) {
      time = '${diff.inDays} D';
    } else if (diff.inDays < 365) {
      time = '${(diff.inDays / 7).floor()} W';
    } else {
      time = '${(diff.inDays / 365).floor()} Y';
    }
    return time;
  }
}
