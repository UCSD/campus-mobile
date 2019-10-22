import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/models/dining_menu_items_model.dart';

class NutritionFactsView extends StatelessWidget {
  const NutritionFactsView({Key key, @required this.data}) : super(key: key);
  final MenuItem data;
  @override
  Widget build(BuildContext context) {
    return nutrientWidget();
  }

  Widget nutrientWidget() {
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
          border: new Border.all(color: Colors.black, width: 2.0)),
      child: Container(
        padding: EdgeInsets.all(2.0),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            nutriHeader(
                calories: data.nutrition.calories,
                servingSize: data.nutrition.servingSize),
          ],
        ),
      ),
    );
  }
}

Widget nutrientValues({nutrientData}) {
  //final n = (1.3456).toStringAsFixed(2);
  //final s = double.parse("1.2345");
  final nutrientTypes = [
    {"nutrient": "FAT", "name": "Total Fat", "sub": false, "dly": 65.0},
    {"nutrient": "SATFAT", "name": "Saturated Fat", "sub": true, "dly": 20.0},
    {"nutrient": "TRANSFAT", "name": "Trans Fat", "sub": true, "dly": null},
    {"nutrient": "CHOLE", "name": "Cholesterol", "sub": false, "dly": 300.0},
    {"nutrient": "NA", "name": "Sodium", "sub": false, "dly": 2400.0},
    {
      "nutrient": "CHOCDF",
      "name": "Total Carbohidrate",
      "sub": false,
      "dly": 300.0,
    },
    {"nutrient": "FIBTG", "name": "Dietary Fiber", "sub": true, "dly": 25.0},
    {"nutrient": "SUGAR", "name": "Sugars", "sub": true, "dly": null},
    {"nutrient": "PROCNT", "name": "Protein", "sub": false, "dly": 50.0},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: nutrientTypes
        .map((d) => nutrientLiner(
              nutrientName: d["name"],
              qty: nutrientData["${d["nutrient"]}"]["amount"],
              ptg: d["dly"] != null
                  ? ((nutrientData["${d["nutrient"]}"]["amount"] * 100) /
                          d["dly"])
                      .toStringAsFixed(2)
                  : "-",
              sub: d["sub"],
              unit: nutrientData["${d["nutrient"]}"]["unit"],
              showp: d["dly"] != null ? true : false,
            ))
        .toList(),
  );
}

Widget vitaminValues({nutrientData}) {
  //final n = (1.3456).toStringAsFixed(2);
  //final s = double.parse("1.2345");
  final nutrientTypes = [
    {"nutrient": "THIA", "name": "Thiamin", "sub": false, "dly": 1.5},
    {"nutrient": "K", "name": "Potassium", "sub": false, "dly": 3500.0},
    {"nutrient": "VITB6A", "name": "Vitamin B6", "sub": false, "dly": 2.0},
    {"nutrient": "VITA_IU", "name": "Vitamin A", "sub": false, "dly": 5000},
    {"nutrient": "VITD", "name": "Vitamin D", "sub": false, "dly": 400},
    {"nutrient": "VITK1", "name": "Vitamin K ", "sub": false, "dly": 80},
  ];
  final vitaminLine = Container(
      margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
      height: 4.0,
      color: Colors.black);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[vitaminLine] +
        nutrientTypes
            .map((d) => vitaminLiner(
                  nutrientName: d["name"],
                  qty: nutrientData["${d["nutrient"]}"]["amount"],
                  ptg: d["dly"] != null
                      ? ((nutrientData["${d["nutrient"]}"]["amount"] * 100) /
                              d["dly"])
                          .toStringAsFixed(2)
                      : "-",
                  unit: nutrientData["${d["nutrient"]}"]["unit"],
                  showp: d["dly"] != null ? true : false,
                ))
            .toList(),
  );
}

Widget nutriHeader({calories, servingSize, servings}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        "Nutrition Facts",
        textAlign: TextAlign.left,
        style: TextStyle(
            color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.w700),
      ),
      Text(
        "Serving Size $servingSize",
        style: TextStyle(
            fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w400),
      ),
      Container(
        margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 5.0,
        color: Colors.black,
      ),
      Text(
        "Ammount Per Serving",
        style: TextStyle(
            fontSize: 10.0, color: Colors.black, fontWeight: FontWeight.w800),
      ),
      Container(
        margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 1.0,
        color: Colors.black,
      ),
      Row(children: <Widget>[
        Text(
          "Calories",
          style: TextStyle(
              fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w900),
        ),
        Text(
          " $calories",
          style: TextStyle(
              fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ]),
      Container(
          margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
          height: 3.0,
          color: Colors.black),
      Container(
        alignment: Alignment.topRight,
        child: Text(
          "% Daily Value*",
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),
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
  unit: "g",
  showp: true,
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
              "  ${qty}${unit}",
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.black,
                  fontWeight: textWeight2),
            ),
            Expanded(
                child: Text(
              (((ptg == null) || !showp) ? "" : "${ptg}%"),
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

Widget vitaminLiner({
  @required nutrientName,
  @required qty,
  ptg,
  showQty: false,
  unit: "g",
  showp: true,
}) {
  final textSize = 15.0;
  final textWeight = FontWeight.w500;
  return Container(
      padding: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
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
                  fontWeight: textWeight),
            ),
            Text(
              (showQty) ? "  ${qty}${unit}" : "",
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.black,
                  fontWeight: textWeight),
            ),
            Expanded(
                child: Text(
              (((ptg == null) || !showp) ? "" : "${ptg}%"),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.black,
                fontWeight: textWeight,
              ),
            )),
          ],
        )
      ]));
}

Widget footerCalories({caloriesNum: 2000}) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
          height: 5.0,
          color: Colors.black,
        ),
        Text(
          "Percent Daily Values are based on a ${caloriesNum} calories diet.",
          style: TextStyle(
              fontSize: 10.0, color: Colors.black, fontWeight: FontWeight.w400),
        )
      ]);
}
