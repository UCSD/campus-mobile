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
      style: TextStyle(),
    );
  }

  Widget buildCardContent(
      StudentIdBarcodeModel barcodeModel,
      StudentIdNameModel nameModel,
      StudentIdPhotoModel photoModel,
      StudentIdProfileModel profileModel,
      BuildContext context) {
    return Row(children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: cardMargin * 1.5),
      ),
      Container(
        child: Column(
          children: <Widget>[
            Image.network(
              photoModel.photoUrl,
              fit: BoxFit.contain,
              height: ScalingUtility.safeBlockVertical * 14,
            ),
            SizedBox(height: ScalingUtility.safeBlockVertical * 1.25),
            Text(profileModel.classificationType),
          ],
        ),
        padding: EdgeInsets.only(
          left: cardMargin,
          right: 20,
        ),
      ),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: new EdgeInsets.only(right: cardMargin),
                child: Text(
                  (nameModel.firstName + " " + nameModel.lastName),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.left,
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: new EdgeInsets.only(right: cardMargin),
                child: Text(
                  profileModel.collegeCurrent,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.left,
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: new EdgeInsets.only(right: cardMargin),
                child: Text(
                  profileModel.ugPrimaryMajorCurrent,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: ScalingUtility.safeBlockVertical * .6),

              ),
              FlatButton(
                child: returnBarcodeContainer(
                    barcodeModel.barCode.toString(), false, context),
                padding: EdgeInsets.all(0),
                onPressed: () {
                  createAlertDialog(
                      context,
                      returnBarcodeContainer(
                          barcodeModel.barCode.toString(), true, context));
                },
              ),
            ]),
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
            fontSize: 1),
      );
    } else {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: ScalingUtility.safeBlockHorizontal * 50,
        height: 40,
        style: TextStyle(
            letterSpacing: ScalingUtility.safeBlockHorizontal * 1.5,
            fontSize: 1,
            color: Colors.white),
      );
    }

    if (rotated) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            RotatedBox(
              quarterTurns: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Container(
                    padding: EdgeInsets.only(left: ScalingUtility.safeBlockVertical * 10),
                    child: barcodeWithText,
                    color: Colors.white,
                  ),
                  Text(
                    cardNumber,
                    style: TextStyle(

                        color: Colors.black,
                        letterSpacing: ScalingUtility.safeBlockVertical * 2.25),
                  )
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
            fontSize: 10.0,
            color: decideColor(Theme.of(context)),
          ),
        ),
        Container(
          padding: addPadding(Theme.of(context)),
          color: Colors.white,
          child: barcodeWithText,
        ),
        Text(
          cardNumber,
          style: TextStyle(letterSpacing: ScalingUtility.safeBlockHorizontal * 1.5),
        ),
      ]);
    }
  }
}

/// Determine padding of barcode with theme
EdgeInsets addPadding(ThemeData currentTheme) {
  return currentTheme.brightness == Brightness.dark
      ? EdgeInsets.all(5)
      : EdgeInsets.all(0);
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
