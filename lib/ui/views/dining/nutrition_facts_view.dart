import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class NutritionFactsView extends StatelessWidget {
  const NutritionFactsView(
      {Key key, @required this.data, this.disclaimer, this.disclaimerEmail})
      : super(key: key);
  final MenuItem data;
  final String disclaimer;
  final String disclaimerEmail;
  @override
  Widget build(BuildContext context) {
    return ContainerView(child: nutrientWidget(context));
  }

  Widget nutrientWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
          border: new Border.all(color: Colors.black, width: 2.0)),
      child: Container(
        padding: EdgeInsets.all(2.0),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            buildTitle(data.name, context),
            nutrientHeader(data.nutrition.calories, data.nutrition.servingSize),
            nutrientValues(nutrientData: data.nutrition.toJson()),
            footerCalories(2000),
            buildText(data.nutrition.ingredients, data.nutrition.allergens),
            disclaimerEmail != null ? buildEmailButton(context) : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String name, BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.title.color,
      ),
    );
  }

  Widget buildText(String ingredients, String allergens) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        children: [
          TextSpan(
            text: "Ingredients: ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ingredients),
          TextSpan(
            text: "\n\nAllergens: ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: allergens),
          TextSpan(
            text: "\n\nDisclaimer: ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: disclaimer),
        ],
      ),
    );
  }

  Widget buildEmailButton(BuildContext context) {
    return FlatButton(
      child: Text('Contact Nutrition Team'),
      onPressed: () {
        ///TODO open up email with disclaimerEmail as the recipient
      },
      color: Theme.of(context).buttonColor,
      textColor: Theme.of(context).textTheme.button.color,
    );
  }
}

Widget nutrientValues({nutrientData}) {
  //final n = (1.3456).toStringAsFixed(2);
  //final s = double.parse("1.2345");
  final nutrientTypes = [
    {"nutrient": "totalFat", "name": "Total Fat", "sub": false, "dly": 65.0},
    {
      "nutrient": "saturatedFat",
      "name": "Saturated Fat",
      "sub": true,
      "dly": 20.0
    },
    {"nutrient": "transFat", "name": "Trans Fat", "sub": true, "dly": null},
    {
      "nutrient": "cholesterol",
      "name": "Cholesterol",
      "sub": false,
      "dly": 300.0
    },
    {"nutrient": "sodium", "name": "Sodium", "sub": false, "dly": 2400.0},
    {
      "nutrient": "totalCarbohydrate",
      "name": "Total Carbohydrate",
      "sub": false,
      "dly": 300.0,
    },
    {
      "nutrient": "dietaryFiber",
      "name": "Dietary Fiber",
      "sub": true,
      "dly": 25.0
    },
    {"nutrient": "sugar", "name": "Sugar", "sub": true, "dly": null},
    {"nutrient": "protein", "name": "Protein", "sub": false, "dly": 50.0},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: nutrientTypes
        .map((d) => nutrientLiner(
              nutrientName: d["name"],
              qty: nutrientData["${d["nutrient"]}"],
              ptg: nutrientData["${d["nutrient"]}" + "_DV"] != null
                  ? nutrientData["${d["nutrient"]}" + "_DV"]
                  : "",
              sub: d["sub"],
              showPercent: d["dly"] != null ? true : false,
            ))
        .toList(),
  );
}

Widget nutrientHeader(String calories, String servingSize) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        "Nutrition Facts",
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w700),
      ),
      Text(
        "Serving Size $servingSize",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
      ),
      Container(
        margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 5.0,
        color: Colors.black,
      ),
      Text(
        "Ammount Per Serving",
        style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w800),
      ),
      Container(
        margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 1.0,
      ),
      Row(children: <Widget>[
        Text(
          "Calories",
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w900),
        ),
        Text(
          " $calories",
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
        ),
      ]),
      Container(
        margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 3.0,
      ),
      Container(
        alignment: Alignment.topRight,
        child: Text(
          "% Daily Value*",
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
        ),
      )
    ],
  );
}

Widget nutrientLiner({
  @required nutrientName,
  @required qty,
  ptg,
  sub: false,
  showPercent: true,
}) {
  final textSize = 15.0;
  final textWeight1 = FontWeight.w900;
  final textWeight2 = FontWeight.w500;
  return Container(
      padding: (sub)
          ? EdgeInsetsDirectional.only(start: 26.0, end: 1.0)
          : EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
      child: Column(children: <Widget>[
        Container(
            margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
            height: 1.0,
            color: Colors.black),
        Row(
          children: <Widget>[
            Text(
              nutrientName,
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.black,
                  fontWeight: (sub) ? textWeight2 : textWeight1),
            ),
            Text(
              "  $qty",
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.black,
                  fontWeight: textWeight2),
            ),
            Expanded(
                child: Text(
              (((ptg == null) || !showPercent) ? "" : "$ptg"),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.black,
                fontWeight: textWeight1,
              ),
            )),
          ],
        )
      ]));
}

Widget footerCalories(int calories) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
          height: 5.0,
          color: Colors.black,
        ),
        Text(
          "Percent Daily Values are based on a $calories calories diet.",
          style: TextStyle(
              fontSize: 10.0, color: Colors.black, fontWeight: FontWeight.w400),
        )
      ]);
}
