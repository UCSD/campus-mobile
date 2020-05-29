import 'package:campus_mobile_experimental/core/constants/notifications_constants.dart';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pagination_view/pagination_view.dart';

class NotificationsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildListView(context);
  }

  Widget buildListView(BuildContext context) {
    return PaginationView<MessageElement>(
      itemBuilder: _buildMessage,
      paginationViewType: PaginationViewType.listView,
      pageFetch: (_) =>
          Provider.of<MessagesDataProvider>(context, listen: false)
              .fetchMessages(false),
      pageRefresh: (_) =>
          Provider.of<MessagesDataProvider>(context, listen: false)
              .fetchMessages(true),
      pullToRefresh: true,
      onError: (dynamic error) => Center(
        child: Text(NotificationsConstants.statusFetchProblem),
      ),
      onEmpty: Center(
        child: Text(NotificationsConstants.statusNoMessages),
      ),
      bottomLoader: Center(
        child: CircularProgressIndicator(),
      ),
      initialLoader: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, MessageElement data, int index) {
    return Column(children: [
      ListTile(
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
          subtitle: Linkify(
              text: data.message.message,
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
              options: LinkifyOptions(humanize: false),
              style: TextStyle(fontSize: 12.5))),
      Divider()
    ]);
  }

  String _readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds < 60) {
      if (diff.inSeconds.floor() == 1) {
        time = diff.inMinutes.toString() + ' SECOND AGO';
      } else {
        time = diff.inMinutes.toString() + ' SECONDS AGO';
      }
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
