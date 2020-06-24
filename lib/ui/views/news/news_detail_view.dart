import 'package:campus_mobile_experimental/core/models/news_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({Key key, @required this.data}) : super(key: key);
  final Item data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: buildDetailView(context),
      ),
    );
  }

  List<Widget> buildDetailView(BuildContext context) {
    return [
      Center(
        child: ImageLoader(
          url: data.image,
          fullSize: true,
        ),
      ),
      Text(
        data.title,
        style: TextStyle(
          fontSize: 26,
        ),
      ),
      SizedBox(height: 4),
      Text(
        DateFormat.yMMMMd().format(data.date),
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 20),
      Linkify(
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        text: data.description,
        style: TextStyle(fontSize: 18),
        options: LinkifyOptions(humanize: false),
      ),
      SizedBox(height: 20),
      Center(
        child: Container(
          height: 40,
          width: double.infinity,
          child: FlatButton(
            color: Theme.of(context).buttonColor,
            onPressed: () {
              launch(data.link);
            },
            child: Text(
              'Continue Reading',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.button.color),
            ),
          ),
        ),
      ),
    ];
  }
}
