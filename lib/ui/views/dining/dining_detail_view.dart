import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/core/models/dining_model.dart' as prefix0;
import 'package:campus_mobile_beta/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/ui/widgets/container_view.dart';
import 'package:campus_mobile_beta/ui/widgets/image_loader.dart';

class DiningDetailView extends StatelessWidget {
  const DiningDetailView({Key key, @required this.data}) : super(key: key);
  final DiningModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildDetailView(),
      ),
    );
  }

  List<Widget> buildDetailView() {
    return [
      Text(
        data.name,
        textAlign: TextAlign.start,
        style: TextStyle(color: ColorPrimary, fontSize: 20.0),
      ),
      Text(
        data.description,
        textAlign: TextAlign.start,
      ),
      Text(
        "Hours",
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      buildHours(),
      buildPaymentOptions(),
      buildPictures(),
    ];
  }

  Widget buildHours() {
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
            Text(data.regularHours.mon),
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
            Text(data.regularHours.mon),
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
            Text(data.regularHours.mon),
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
            Text(data.regularHours.mon),
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
            Text(data.regularHours.mon),
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
            Text(data.regularHours.mon),
            buildGreenDot(),
          ],
        )
      ],
    );
    return Column(children: [
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday,
      sunday
    ]);
  }

  Widget buildPaymentOptions() {
    String options = data.paymentOptions.join(', ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Options: ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            options,
            softWrap: true,
          ),
        )
      ],
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
