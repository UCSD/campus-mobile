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

class StudentIdCard extends StatelessWidget {
  String cardId = "student_id";
  var barcodeImage;

  createAlertDialog(BuildContext context, Column image) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Student ID"),
            content: Container(
              child: image,
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text("X"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return CardContainer(
      /// TODO: need to hook up hidden to state using provider
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
    );
  }

  Widget buildCardContent(
      StudentIdBarcodeModel barcodeModel,
      StudentIdNameModel nameModel,
      StudentIdPhotoModel photoModel,
      StudentIdProfileModel profileModel,
      BuildContext context) {
    return Row(
        children: <Widget>[
          Padding(
           padding: EdgeInsets.only(left: cardMargin * 1.5),
          ),
      Container(
        child: Column(
          children: <Widget>[
            Image.network(
              photoModel.photoUrl,
              fit: BoxFit.contain,
              height: 125,
            ),
            SizedBox(height: 10),
            Text(profileModel.classificationType),
          ],
        ),
        padding: EdgeInsets.only(
          left: cardMargin,
          right: 20,
        ),
      ),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
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
              profileModel.ugPrimaryMajorCurrent ,
              style: TextStyle( fontSize: 16),
              textAlign: TextAlign.left,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
          ),

          FlatButton(
            child: returnBarcodeContainer(barcodeModel.barCode.toString(), false, context),
            onPressed: () {
              createAlertDialog(context,
                  returnBarcodeContainer(barcodeModel.barCode.toString(), true, context));
            },
          ),
        ]),
      ),
    ]);
  }

  returnBarcodeContainer(String cardNumber, bool rotated, BuildContext context) {
    var barcodeWithText;
    SizeConfig().init(context);
    if (rotated) {

     barcodeWithText = BarcodeWidget(
       barcode: Barcode.codabar(),
       data: "A" + cardNumber + "B",
       width: SizeConfig.safeBlockVertical * 60 ,
       height: 80,
       style: TextStyle(
         letterSpacing: SizeConfig.safeBlockVertical * 2.5
       ),
     );
    } else {
      barcodeWithText = BarcodeWidget(
      barcode: Barcode.codabar(),
    data: "A" + cardNumber + "B",
    width: SizeConfig.safeBlockHorizontal * 70 ,
    height: 50,
        style: TextStyle(
            letterSpacing: SizeConfig.safeBlockHorizontal * 1.5
        ),
    );
    }

    if (rotated) {
      return
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(25),
            ),
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                child: barcodeWithText,
              ),
            ),
          ]);
    } else {
      return

      Column(children: <Widget>[
        Text(
          "(tap for easier scanning)"
        ),
        Container(
          child: barcodeWithText,
        ),
      ]);
    }
  }
}


//Image Scaling

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth -
        _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight -
        _safeAreaVertical) / 100;
  }
}