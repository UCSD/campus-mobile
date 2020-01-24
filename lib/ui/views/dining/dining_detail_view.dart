import 'package:campus_mobile_experimental/core/models/dining_model.dart'
    as prefix0;
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/image_loader.dart';
import 'package:campus_mobile_experimental/ui/views/dining/dining_menu_list.dart';

class DiningDetailView extends StatelessWidget {
  const DiningDetailView({Key key, @required this.data}) : super(key: key);
  final prefix0.DiningModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView(
        children: buildDetailView(context, data),
      ),
    );
  }

  List<Widget> buildDetailView(
      BuildContext context, prefix0.DiningModel model) {
    return [
      Text(
        model.name,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: Theme.of(context).textTheme.title.color,
            fontSize: Theme.of(context).textTheme.title.fontSize),
      ),
      Text(
        model.description,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color,
            fontSize: Theme.of(context).textTheme.subtitle.fontSize),
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
        Text('Satuday: '),
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
