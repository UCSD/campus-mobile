import 'package:campus_mobile_experimental/core/models/dining_model.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/widgets/image_loader.dart';
import 'package:campus_mobile_experimental/ui/views/dining/dining_menu_list.dart';

class DiningDetailView extends StatelessWidget {
  const DiningDetailView({Key key, @required this.data}) : super(key: key);
  final prefix0.DiningModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView(
        children: buildDetailView(context),
      ),
    );
  }

  List<Widget> buildDetailView(BuildContext context) {
    return [
      Text(
        data.name,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: Theme.of(context).textTheme.title.color,
            fontSize: Theme.of(context).textTheme.title.fontSize),
      ),
      Text(
        data.description,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color,
            fontSize: Theme.of(context).textTheme.subtitle.fontSize),
      ),
      buildHours(context),
      buildPaymentOptions(context),
      buildPictures(),
      DiningMenuList(id: data.id),
    ];
  }

  Widget buildHours(BuildContext context) {
    Widget monday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Monday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.mon),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget tuesday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Tuesday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.tue),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget wednesday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Wednesday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.wed),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget thursday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Thursday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.thu),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget friday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Friday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.fri),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget saturday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Satuday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.sat),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget sunday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Sunday: '),
        Row(
          children: <Widget>[
            Text(data.regularHours.sun),
            buildGreenDot(),
          ],
        )
      ],
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Hours:",
        textAlign: TextAlign.start,
        style:
            TextStyle(fontWeight: Theme.of(context).textTheme.title.fontWeight),
      ),
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday,
      sunday
    ]);
  }

  Widget buildPaymentOptions(BuildContext context) {
    String options = data.paymentOptions.join(', ');
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.body1.fontSize,
            color: Theme.of(context).textTheme.body1.color),
        children: [
          TextSpan(
            text: "Payment Options:\n",
            style: TextStyle(
                fontWeight: Theme.of(context).textTheme.subtitle.fontWeight),
          ),
          TextSpan(text: options),
        ],
      ),
    );
  }

  Widget buildPictures() {
    List<ImageLoader> images = List<ImageLoader>();
    for (prefix0.Image item in data.images) {
      images.add(ImageLoader(
        url: item.small,
      ));
    }
    return Center(
      child: Container(
        height: 100,
        child: ListView.separated(
          itemCount: images.length,
          itemBuilder: (BuildContext context, int index) {
            return images[index];
          },
          separatorBuilder: (BuildContext context, int index) {
            return Container(width: 10);
          },
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Widget buildGreenDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
    );
  }
}
