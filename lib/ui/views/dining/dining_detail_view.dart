import 'package:campus_mobile_experimental/core/models/dining_model.dart'
    as prefix0;
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/image_loader.dart';
import 'package:campus_mobile_experimental/ui/views/dining/dining_menu_list.dart';
import 'package:flutter/material.dart';

class DiningDetailView extends StatelessWidget {
  const DiningDetailView({Key key, @required this.data}) : super(key: key);
  final prefix0.DiningModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView.separated(
        itemCount: buildDetailView(context, data).length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 8);
        },
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return buildDetailView(context, data)[index];
        },
      ),
    );
  }

  List<Widget> buildDetailView(
      BuildContext context, prefix0.DiningModel model) {
    return [
      Text(
        model.name,
        textAlign: TextAlign.start,
        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 26),
      ),
      Text(
        model.description,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color, fontSize: 15),
      ),
      buildHours(context, model),
      buildPaymentOptions(context, model),
      buildPictures(model),
      DiningMenuList(
        id: model.id,
      ),
    ];
  }

  Widget buildHours(BuildContext context, prefix0.DiningModel model) {
    Widget monday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Monday: '),
        Row(
          children: <Widget>[
            Text(model.regularHours.mon),
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
            Text(model.regularHours.tue),
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
            Text(model.regularHours.wed),
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
            Text(model.regularHours.thu),
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
            Text(model.regularHours.fri),
            buildGreenDot(),
          ],
        )
      ],
    );
    Widget saturday = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Saturday: '),
        Row(
          children: <Widget>[
            model.regularHours.sat != null
                ? Text(model.regularHours.sat)
                : Text('Closed'),
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
            model.regularHours.sun != null
                ? Text(model.regularHours.sun)
                : Text('Closed'),
            buildGreenDot(),
          ],
        )
      ],
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Hours:",
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      SizedBox(height: 6),
      monday,
      SizedBox(height: 10),
      tuesday,
      SizedBox(height: 10),
      wednesday,
      SizedBox(height: 10),
      thursday,
      SizedBox(height: 10),
      friday,
      SizedBox(height: 10),
      saturday,
      SizedBox(height: 10),
      sunday
    ]);
  }

  Widget buildPaymentOptions(BuildContext context, prefix0.DiningModel model) {
    String options = model.paymentOptions.join(', ');
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

  Widget buildPictures(prefix0.DiningModel model) {
    List<ImageLoader> images = List<ImageLoader>();
    if (model.images != null && model.images.length > 0) {
      for (prefix0.Image item in model.images) {
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
    return Container(height: 10);
  }

  Widget buildGreenDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
    );
  }
}
