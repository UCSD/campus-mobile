import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({Key? key, required this.data}) : super(key: key);
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
        data.title!,
        style: TextStyle(
          fontSize: 26,
        ),
      ),
      SizedBox(height: 4),
      Text(
        DateFormat.yMMMMd().format(data.date!),
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 20),
      LinkifyWithCatch(
        text: data.description,
        style: TextStyle(fontSize: 18),
      ),
      SizedBox(height: 20),
      ContinueReadingButton(
        link: data.link,
      ),
    ];
  }
}

class ContinueReadingButton extends StatelessWidget {
  final String? link;

  const ContinueReadingButton({Key? key, this.link}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 40,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onPrimary: Theme.of(context).primaryColor, // foreground
            // primary: Theme.of(context).buttonColor,
            primary: Theme.of(context).backgroundColor,
          ),
          onPressed: () async {
            try {
              await launch(link!, forceSafariVC: true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Could not open.'),
              ));
            }
          },
          child: Text(
            'Continue Reading',
            style: TextStyle(
                fontSize: 18, color: Theme.of(context).textTheme.button!.color),
          ),
        ),
      ),
    );
  }
}
