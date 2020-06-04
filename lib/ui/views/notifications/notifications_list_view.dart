import 'package:campus_mobile_experimental/core/constants/notifications_constants.dart';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          return ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) =>
                _buildLoadingIndicator(),
            controller:
                Provider.of<MessagesDataProvider>(context).scrollController,
            itemCount: 1,
            separatorBuilder: (BuildContext context, int index) => Divider(),
          );
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

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
      ],
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

  Widget _buildMessage(BuildContext context, int index) {
    MessageElement data =
        Provider.of<MessagesDataProvider>(context).messages[index];
    if (index ==
        Provider.of<MessagesDataProvider>(context).messages.length - 1) {
      if (Provider.of<MessagesDataProvider>(context).hasMoreMessagesToLoad) {
        return _buildLoadingIndicator();
      } else {
        return Container();
      }
    }
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
        style: TextStyle(fontSize: 12.5),
      ),
    );
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
