import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/student_id_barcode.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentIdCard extends StatefulWidget {
  @override
  _StudentIdCardState createState() => _StudentIdCardState();
}

class _StudentIdCardState extends State<StudentIdCard> {
  String cardId = "student_id";

  /// Pop up barcode
  createAlertDialog(
      BuildContext context, Column image, String cardNumber, bool rotated) {
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
              child: checkForRotation(image, context, cardNumber, rotated),
            ),
            actions: <Widget>[
              TextButton(
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  Column checkForRotation(
      Column image, BuildContext context, String cardNumber, bool rotated) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return returnBarcodeContainer(cardNumber, rotated, context);
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    ScalingUtility().getCurrentMeasurements(context);

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
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
        fontSize: ScalingUtility.horizontalSafeBlock * 2,
      ),
    );
  }

  Widget buildCardContent(
      StudentIdBarcodeModel? barcodeModel,
      StudentIdNameModel? nameModel,
      StudentIdPhotoModel? photoModel,
      StudentIdProfileModel? profileModel,
      BuildContext context) {
    try {
      if (MediaQuery.of(context).size.width < 600) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: (Row(children: <Widget>[
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
                          photoModel!.photoUrl!,
                          fit: BoxFit.contain,
                          height: ScalingUtility.verticalSafeBlock * 14,
                        ),
                        SizedBox(
                          height: ScalingUtility.verticalSafeBlock * 1.5,
                        )
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: cardMargin * 1.5, right: cardMargin * 1.5)),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: new EdgeInsets.only(
                                right: ScalingUtility.horizontalSafeBlock *
                                    cardMargin),
                            child: FittedBox(
                              child: Text(
                                (nameModel!.firstName! +
                                    " " +
                                    nameModel.lastName!),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: getFontSize(
                                        nameModel.firstName! +
                                            " " +
                                            nameModel.lastName!,
                                        "name")),
                                textAlign: TextAlign.left,
                                softWrap: true,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: ScalingUtility.verticalSafeBlock * .5),
                          Container(
                            padding: new EdgeInsets.only(
                                right: ScalingUtility.horizontalSafeBlock *
                                    cardMargin),
                            child: Text(
                              profileModel!.collegeCurrent!,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: getFontSize(
                                      profileModel.collegeCurrent!, "college")),
                              textAlign: TextAlign.left,
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                              height: ScalingUtility.verticalSafeBlock * .5),
                          Container(
                            padding: new EdgeInsets.only(
                                right: ScalingUtility.horizontalSafeBlock *
                                    cardMargin),
                            child: Text(
                              profileModel.graduatePrimaryMajorCurrent != ""
                                  ? profileModel.graduatePrimaryMajorCurrent
                                  : profileModel.ugPrimaryMajorCurrent!,
                              style: TextStyle(
                                  fontSize: getFontSize(
                                      profileModel.graduatePrimaryMajorCurrent !=
                                              ""
                                          ? profileModel
                                              .graduatePrimaryMajorCurrent
                                          : profileModel.ugPrimaryMajorCurrent!,
                                      "major")),
                              textAlign: TextAlign.left,
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                                ScalingUtility.verticalSafeBlock * .9),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: returnBarcodeContainer(
                                barcodeModel!.barCode.toString(),
                                false,
                                context),
                            onPressed: () {
                              createAlertDialog(
                                  context,
                                  returnBarcodeContainer(
                                      barcodeModel.barCode.toString(),
                                      true,
                                      context),
                                  barcodeModel.toString(),
                                  true);
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
                          left:
                              ScalingUtility.horizontalSafeBlock * cardMargin),
                      child: Text(
                        profileModel.classificationType!,
                        style: TextStyle(
                            fontSize: ScalingUtility.horizontalSafeBlock * 3.5),
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left:
                                (ScalingUtility.horizontalSafeBlock * 11.225) +
                                    realignText(Theme.of(context))),
                        child: Text(
                          barcodeModel.barCode.toString(),
                          style: TextStyle(
                              fontSize: ScalingUtility.horizontalSafeBlock * 3,
                              letterSpacing:
                                  ScalingUtility.horizontalSafeBlock * 1.5),
                        ),
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ])),
        );
      } else {
        return (Row(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: cardMargin * 1.5),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Image.network(
                  photoModel!.photoUrl!,
                  fit: BoxFit.contain,
                  height: 125,
                ),
                SizedBox(height: 10),
                Text(profileModel!.classificationType!),
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
                      (nameModel!.firstName! + " " + nameModel.lastName!),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: tabletFontSize(
                              nameModel.firstName! + " " + nameModel.lastName!,
                              "name")),
                      textAlign: TextAlign.left,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: new EdgeInsets.only(right: cardMargin),
                    child: Text(
                      profileModel.collegeCurrent!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: tabletFontSize(
                              profileModel.collegeCurrent!, "college")),
                      textAlign: TextAlign.left,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: new EdgeInsets.only(right: cardMargin),
                    child: Text(
                      profileModel.graduatePrimaryMajorCurrent != ""
                          ? profileModel.graduatePrimaryMajorCurrent
                          : profileModel.ugPrimaryMajorCurrent!,
                      style: TextStyle(
                          fontSize: tabletFontSize(
                              profileModel.graduatePrimaryMajorCurrent != ""
                                  ? profileModel.graduatePrimaryMajorCurrent
                                  : profileModel.ugPrimaryMajorCurrent!,
                              "major")),
                      textAlign: TextAlign.left,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                    ),
                    child: returnBarcodeContainerTablet(
                        barcodeModel!.barCode.toString(), false, context),
                    onPressed: () {
                      createAlertDialog(
                          context,
                          returnBarcodeContainer(
                              barcodeModel.barCode.toString(), true, context),
                          barcodeModel.barCode.toString(),
                          true);
                    },
                  ),
                ]),
          ),
        ]));
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          e, StackTrace.fromString(e.toString()),
          reason: "Student ID Card: Failed to build card content.",
          fatal: false);
      return Container(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 32, bottom: 48),
            child: Container(
              child: Text(
                  "Your Student ID could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu"),
            ),
          ),
        ),
      );
    }
  }

  /// Determine barcode to display
  returnBarcodeContainer(
      String cardNumber, bool rotated, BuildContext context) {
    var barcodeWithText;

    /// Initialize sizing
    ScalingUtility().getCurrentMeasurements(context);
    if (rotated) {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: ScalingUtility.verticalSafeBlock * 45,
        height: 80,
        style: TextStyle(
            letterSpacing: ScalingUtility.verticalSafeBlock * 3,
            color: Colors.white,
            fontSize: 0),
      );
    } else {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: ScalingUtility.horizontalSafeBlock * 50,
        height: ScalingUtility.verticalSafeBlock * 4.45,
        style: TextStyle(
            letterSpacing: ScalingUtility.horizontalSafeBlock * 1.5,
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
                        EdgeInsets.all(ScalingUtility.verticalSafeBlock * 7.5),
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
                            fontSize: fontSizeForTablet(),
                            letterSpacing: letterSpacingForTablet()),
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
            fontSize: ScalingUtility.horizontalSafeBlock * 2.5,
            color: decideColor(Theme.of(context)),
          ),
        ),
        Container(
          padding: addBorder(Theme.of(context)),
          color: Colors.white,
          child: barcodeWithText,
        ),
      ]);
    }
  }

  double letterSpacingForTablet() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return ScalingUtility.horizontalSafeBlock * 1;
    }
    return ScalingUtility.horizontalSafeBlock * 3;
  }

  double fontSizeForTablet() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return ScalingUtility.horizontalSafeBlock * 2;
    }
    return ScalingUtility.horizontalSafeBlock * 4;
  }

  returnBarcodeContainerTablet(
      String cardNumber, bool rotated, BuildContext context) {
    var barcodeWithText;
    SizeConfig().init(context);
    if (rotated) {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: SizeConfig.safeBlockVertical * 60,
        height: 80,
        style: TextStyle(
            letterSpacing: SizeConfig.safeBlockVertical * 3,
            fontSize: 0,
            color: Colors.white),
      );
    } else {
      barcodeWithText = BarcodeWidget(
        barcode: Barcode.codabar(),
        data: cardNumber,
        width: SizeConfig.safeBlockHorizontal * 20,
        height: 40,
        style: TextStyle(
            letterSpacing: SizeConfig.safeBlockHorizontal * 1.5,
            fontSize: 0,
            color: Colors.white),
      );
    }

    if (rotated) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(25),
            ),
            RotatedBox(
              quarterTurns: 1,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 7.5),
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
                            fontSize: getRotatedPopUpFontSize(),
                            letterSpacing: letterSpacing()),
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
            fontSize: 10.0,
            color: decideColor(Theme.of(context)),
          ),
        ),
        Container(
          padding: addBorder(Theme.of(context)),
          color: Colors.white,
          child: barcodeWithText,
        ),
        Text(
          cardNumber,
          style: TextStyle(
              fontSize: ScalingUtility.horizontalSafeBlock * 1.25,
              letterSpacing: ScalingUtility.horizontalSafeBlock * .5),
        ),
      ]);
    }
  }

  double letterSpacing() =>
      MediaQuery.of(context).orientation == Orientation.landscape
          ? SizeConfig.safeBlockHorizontal * 1
          : SizeConfig.safeBlockHorizontal * 3;

  double getRotatedPopUpFontSize() =>
      MediaQuery.of(context).orientation == Orientation.landscape
          ? SizeConfig.safeBlockHorizontal * 2
          : SizeConfig.safeBlockHorizontal * 4;

  /// Determine the font size for user's textFields
  double getFontSize(String input, String textField) {
    /// Base font size
    double base = ScalingUtility.horizontalSafeBlock * 3.5;

    /// If threshold is passed, shrink text
    if (input.length >= 21) {
      return (base - (0.175 * (input.length - 18)));
    }

    //// The name should be large than subheadings
    if (textField == "name") {
      base = ScalingUtility.horizontalSafeBlock * 5;
      return base;
    }

    return base;
  }

  double tabletFontSize(String input, String textField) {
    /// Base font size
    double base = letterSpacingForTablet();

    /// If threshold is passed, shrink text
    if (input.length >= 21) {
      return (base - (0.1725 * (input.length - 18)));
    }

    //// The name should be large than subheadings
    if (textField == "name") {
      base = ScalingUtility.horizontalSafeBlock * 1.75;
      return base;
    } else {
      base = ScalingUtility.horizontalSafeBlock * 1.25;
      return base;
    }
  }

  /// Determine the padding for a border around barcode
  EdgeInsets addBorder(ThemeData currentTheme) {
    return currentTheme.brightness == Brightness.dark
        ? EdgeInsets.all(5)
        : EdgeInsets.all(0);
  }

  /// Determine the padding for the text to realign
  double realignText(ThemeData currentTheme) {
    return currentTheme.brightness == Brightness.dark ? 7 : 0;
  }

  /// Determine the  color of hint above the barcode
  Color decideColor(ThemeData currentTheme) {
    return currentTheme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black45;
  }
}

//Image Scaling
class ScalingUtility {
  late MediaQueryData _queryData;
  static late double horizontalSafeBlock;
  static late double verticalSafeBlock;

  void getCurrentMeasurements(BuildContext context) {
    /// Find screen size
    _queryData = MediaQuery.of(context);

    /// Calculate blocks accounting for notches and home bar
    horizontalSafeBlock = (_queryData.size.width -
            (_queryData.padding.left + _queryData.padding.right)) /
        100;
    verticalSafeBlock = (_queryData.size.height -
            (_queryData.padding.top + _queryData.padding.bottom)) /
        100;
  }
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
