//import 'dart:io';
// import 'dart:js';

import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/student_id_barcode_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';

import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
import 'package:barcode_flutter/barcode_flutter.dart';



class StudentIdCard extends StatelessWidget {

  String cardId = "student_id";
  var barcodeImage;
  createAlertDialog(BuildContext context, Column image){
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Student ID"),
          content: Container(
            child: image,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("X"),
              onPressed:(){
                Navigator.of(context).pop();
              }
            )
          ],
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    print("start of build");

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

  Widget buildCardContent(StudentIdBarcodeModel barcodeModel, StudentIdNameModel nameModel, StudentIdPhotoModel photoModel,
                            StudentIdProfileModel profileModel, BuildContext context) {
    return Row(children: <Widget>[
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
          left: 10,
          right: 20,
        ),
      ),
     Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
        Text(
          (nameModel.firstName + " " + nameModel.lastName).trim(),
         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
         textAlign: TextAlign.left,
        ),
        Text(
        profileModel.collegeCurrent.trim(),
        style: TextStyle(color: Colors.grey, fontSize: 16),
        textAlign: TextAlign.left,
        ),
      Text(
        profileModel.ugPrimaryMajorCurrent.trim(),
        style: TextStyle(color: Colors.grey, fontSize: 16),
        textAlign: TextAlign.left,
      ),
          Padding(
          padding: EdgeInsets.only(top: 20),
          ),
          //Text(profileModel.collegeCurrent),
          //Text(profileModel.ugPrimaryMajorCurrent),

            FlatButton(
           child: returnBarcodeContainer(barcodeModel.barCode.toString(), false),
              onPressed:(){
                createAlertDialog(context, returnBarcodeContainer(barcodeModel.barCode.toString(), true));
              },
            ),
         /* Text(
              barcodeModel.barCode.toString()),*/ // TODO: NEED UTILITY FOR CONVERTING THIS INTEGER TO A BARCODE
      ]),
    ]);
  }

  returnBarcodeContainer(String cardNumber, bool rotated) {
    var barcodeWithText;
    if(rotated){
      barcodeWithText = BarCodeItem(
          description: "",
          image: BarCodeImage(
            params: CodabarBarCodeParams(
              "A" + cardNumber + "B",
              lineWidth: 2.4,
              withText: true,
            ),
          ));
    }else {
      barcodeWithText = BarCodeItem(
          description: "(tap for easier scanning)",
          image: BarCodeImage(
            params: CodabarBarCodeParams(
              "A" + cardNumber + "B",
              withText: true,
              barHeight: 20,
              lineWidth: 1.0,
              //  barHeight: SizeConfig.safeBlockVertical * 8,
            ),
          ));
    }

    barcodeImage = barcodeWithText.image;

    if(rotated){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(25),
          ),
          RotatedBox(
            quarterTurns: 1,
                child: Container(
                        child: barcodeWithText.image,
                      ),
              ),

        ]);
    }else {
      return Column(
          children: <Widget>[
            Text(
              barcodeWithText.description,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.0,
                color: Colors.black45,
              ),
            ),
            Container(
              child: barcodeWithText.image,
            ),
          ]);
    }
  }
  }



class BarCodeItem {
  String description;
  BarCodeImage image;

  BarCodeItem({
    this.image,
    this.description,
  });
}
