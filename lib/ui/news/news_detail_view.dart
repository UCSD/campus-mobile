import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_styles.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({Key? key, required this.data}) : super(key: key);
  final Item data;

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: data.image.isEmpty
                    ? const AssetImage('assets/images/UCSDMobile_banner.png')
                as ImageProvider
                    : NetworkImage(data.image),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Mimics StartDateContainer from events_detail_view.dart
                NewsDateContainer(
                  date: DateFormat("MMM d y").format(data.date.toLocal()),
                ),
                // Title on the right
                Expanded(
                  child: NewsTitle(title: data.title),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: data.description.isNotEmpty
                ? Text(
              data.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            )
                : Container(),
          ),

          Container(
            padding: const EdgeInsets.only(left: 15, top: 20, right: 248, bottom: 20),
            child: data.link.isNotEmpty
                ? ContinueReadingButton(link: data.link)
                : Container(),
          ),
        ],
      ),
    );
  }
}

class NewsDateContainer extends StatelessWidget {
  final String date;
  const NewsDateContainer({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parts = date.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Month
        Text(
          parts[0].toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).brightness == Brightness.light
                ? lightPrimaryColor
                : Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          parts[1].toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.light
                ? lightPrimaryColor
                : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          parts[2].toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).brightness == Brightness.light
                ? lightPrimaryColor
                : Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class NewsTitle extends StatelessWidget {
  final String title;
  const NewsTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.light
              ? lightPrimaryColor
              : Colors.white,
        ),
      ),
    );
  }
}

class ContinueReadingButton extends StatelessWidget {
  final String link;
  const ContinueReadingButton({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: actionButtonBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        try {
          await launch(link, forceSafariVC: true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open.')),
          );
        }
      },
      child: FittedBox(
        child: Row(
          children: [
            Text(
              'FULL STORY',
              style: TextStyle(fontSize: 18, color: lightPrimaryColor),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 18, color: lightPrimaryColor),
          ],
        ),
      ),
    );
  }
}
