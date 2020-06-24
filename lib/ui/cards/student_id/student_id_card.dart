
//import 'dart:io';
// import 'dart:js';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/student_id_barcode_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class StudentIdCard extends StatefulWidget {
  @override
  _StudentIdCardState createState() => _StudentIdCardState();
}

class _StudentIdCardState extends State<StudentIdCard> {
  String cardId = "student_id";

  createAlertDialog(BuildContext context, Column image) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Student ID",
              style: TextStyle(color: Colors.black),
            ),
            content: Container(
              child: image,
            ),
            actions: <Widget>[
              FlatButton(
                  child: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ScalingUtility().init(context);

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<StudentIdDataProvider>(context, listen: false)
          .fetchData(),
      isLoading: Provider.of<StudentIdDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<StudentIdDataProvider>(context).error,
      child: () => buildCardContent(
          Provider.of<StudentIdDataProvider>(context).studentIdBarcodeModel,
          Provider.of<StudentIdDataProvider>(context).studentIdNameModel,
          Provider.of<StudentIdDataProvider>(context).studentIdPhotoModel,
          Provider.of<StudentIdDataProvider>(context).studentIdProfileModel,
          context),
    );
  }

  Widget buildTitle() {
    return Text(
      "Student ID",
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: ScalingUtility.safeBlockHorizontal * 2,
      ),
    );
  }

  Widget buildCardContent(
      StudentIdBarcodeModel barcodeModel,
      StudentIdNameModel nameModel,
      StudentIdPhotoModel photoModel,
      StudentIdProfileModel profileModel,
      BuildContext context) {
    return Row(children: <Widget>[
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      left: cardMargin * 1.5, right: cardMargin * 1.5)),
              Column(
                children: <Widget>[
                  Image.network(
                    photoModel.photoUrl,
                    fit: BoxFit.contain,
                    height: ScalingUtility.safeBlockVertical * 14,
                  ),
                  SizedBox(
                    height: ScalingUtility.safeBlockVertical * 2,
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: cardMargin * 1.5, right: cardMargin * 1.5)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                Container(
                  padding: new EdgeInsets.only(
                      right: ScalingUtility.safeBlockHorizontal * cardMargin),
                  child: FittedBox(
                    child:Text(
                      (nameModel.firstName + " " + nameModel.lastName),
//                    overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getFontSize(nameModel.firstName + " " + nameModel.lastName, "name")),
                      textAlign: TextAlign.left,
                      softWrap: true,
                      maxLines: 1,
                    ),),
                ),
                SizedBox(height: ScalingUtility.safeBlockVertical * .5),
                Container(
                  padding: new EdgeInsets.only(
                      right: ScalingUtility.safeBlockHorizontal * cardMargin),
                  child: Text(
                    profileModel.collegeCurrent,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize:getFontSize(profileModel.collegeCurrent, "college") ),
                    textAlign: TextAlign.left,
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: ScalingUtility.safeBlockVertical * .5),
                Container(
                  padding: new EdgeInsets.only(
                      right: ScalingUtility.safeBlockHorizontal * cardMargin),
                  child: Text(
                    profileModel.ugPrimaryMajorCurrent,
                    style: TextStyle(
                        fontSize: getFontSize(profileModel.ugPrimaryMajorCurrent, "major")),
                    textAlign: TextAlign.left,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding:
                  EdgeInsets.all(ScalingUtility.safeBlockVertical * .9),
                ),
                FlatButton(
                  child: returnBarcodeContainer(
                      barcodeModel.barCode.toString(), false, context),
                  padding: EdgeInsets.all(0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    createAlertDialog(
                        context,
                        returnBarcodeContainer(
                            barcodeModel.barCode.toString(), true, context));
                  },
                ),
              ]),
            ],
          ),
          Row(children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: ScalingUtility.safeBlockHorizontal * cardMargin),
                child: Text(
                  profileModel.classificationType,
                  style: TextStyle(
                      fontSize: ScalingUtility.safeBlockHorizontal * 3.5),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: (ScalingUtility.safeBlockHorizontal * 11.225) +
                          addPaddingForBarcode(Theme.of(context))),
                  child: Text(
                    barcodeModel.barCode.toString(),
                    style: TextStyle(
                        fontSize: ScalingUtility.safeBlockHorizontal * 3,
                        letterSpacing:
                        ScalingUtility.safeBlockHorizontal * 1.5),
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    ]);
  }

  /// Determine barcode to display
  returnBarcodeContainer(
      String cardNumber, bool rotated, BuildContext context) {
    var barcodeWithText;

    /// Initialize sizing
    ScalingUtility().init(context);
    if (rotated) {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: ScalingUtility.safeBlockVertical * 45,
        height: 80,
        style: TextStyle(
            letterSpacing: ScalingUtility.safeBlockVertical * 3,
            color: Colors.white,
            fontSize: 0),
      );
    } else {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: ScalingUtility.safeBlockHorizontal * 50,
        height: ScalingUtility.safeBlockVertical * 4.45,
        style: TextStyle(
            letterSpacing: ScalingUtility.safeBlockHorizontal * 1.5,
            fontSize: 0,
            color: Colors.white),
      );
    }

    if (rotated) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RotatedBox(
              quarterTurns: 1,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding:
                    EdgeInsets.all(ScalingUtility.safeBlockVertical * 7.5),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: barcodeWithText,
                        color: Colors.white,
                      ),
                      Text(
                        cardNumber,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScalingUtility.safeBlockHorizontal * 4,
                            letterSpacing:
                            ScalingUtility.safeBlockHorizontal * 3),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ]);
    } else {
      return Column(children: <Widget>[
        Text(
          "(tap for easier scanning)",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ScalingUtility.safeBlockHorizontal * 2.5,
            color: decideColor(Theme.of(context)),
          ),
        ),
        Container(
          padding: addPadding(Theme.of(context)),
          color: Colors.white,
          child: barcodeWithText,
        ),
      ]);
    }
  }
}

double getFontSize(String input, String textField) {
  double base = ScalingUtility.safeBlockHorizontal * 4;
  if(input.length >= 21) {
    return (base - (0.25 * (input.length-12)));
  }

  if(textField == "name"){
    base = ScalingUtility.safeBlockHorizontal * 5;
    return base;
  }

  return base;
}

/// Determine padding of barcode with theme
EdgeInsets addPadding(ThemeData currentTheme) {
  return currentTheme.brightness == Brightness.dark
      ? EdgeInsets.all(5)
      : EdgeInsets.all(0);
}

double addPaddingForBarcode(ThemeData currentTheme) {
  return currentTheme.brightness == Brightness.dark ? 7 : 0;
}

/// Determine the background color of barcode with theme
Color decideColor(ThemeData currentTheme) {
  return currentTheme.brightness == Brightness.dark
      ? Colors.white
      : Colors.black45;
}
//Image Scaling

class ScalingUtility {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    /// Find screen size
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    /// Calculate safe area
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}

