import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/survey_data_provider.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyCard extends StatefulWidget {
  SurveyCard();

  @override
  _SurveyCardState createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  String cardId = "student_survey";
  double _contentHeight = webViewMinHeight;
  SurveyDataProvider _surveyDataProvider;
  UserDataProvider _userDataProvider;
  WebViewController _webViewController;
  String surveyIdMessage = "";
  List<String> postMessage;
  String surveyID = "";
  bool displayCard = true;
  int i = 0;
  String surveyURL;

//  bool hasSubmitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _surveyDataProvider = Provider.of<SurveyDataProvider>(context);
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
//    if (surveyID == userProfile) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => null,
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

//  final _url =
//      "https://mobile.ucsd.edu/replatform/v1/qa/webview/student_survey.html";

  Widget buildCardContent(BuildContext context) {
    print("survey completion: ");
    print(_userDataProvider.userProfileModel.surveyCompletion.toString());
    _surveyDataProvider.surveyModels.forEach((survey) {
      //sets the active survey url and survey id
      if (survey.surveyActive == true) {
        surveyURL = survey.surveyUrl;
        surveyID = survey.surveyId;
        print("active survey url: " + surveyURL);
        print("active survey id: " + surveyID);
      }

      ///IF THE CURRENT SURVEY IS NOT ACTIVE AND COMPLETED
      if (survey.surveyActive != true &&
          _userDataProvider.userProfileModel.surveyCompletion
              .contains(surveyID)) {
        print("survey card is not displayed");
        displayCard = false;
      }
    });

    ///IF NO SURVEYS ARE ACTIVE
    if (surveyURL == null) {
//      displayCard = false;
      return Container(
        height: _contentHeight,
        child: Text(
          "Survey not available, check back later.",
          style: TextStyle(
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (displayCard == true) {
      print("survey card is displayed");

      return Container(
        height: _contentHeight + 50,
        child: WebView(
          opaque: false,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: surveyURL,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _printJavascriptChannel(context),
          ].toSet(),
        ),
      );
    }
    //Thank you for submitting text widget
    return buildSubmissionCardContent(context);
  }

  Widget buildSubmissionCardContent(BuildContext context) {
    return Container(
      height: _contentHeight,
      child: Text(
        "Thank you for submitting all the forms!",
        style: TextStyle(
          fontSize: 22,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  JavascriptChannel _printJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'CampusMobile',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
        postMessage = message.message.split("###");
        surveyIdMessage = postMessage[1];
        print(postMessage[1]);
        _surveyDataProvider.submitSurvey(surveyIdMessage);
//        Provider.of<SurveyDataProvider>(context, listen: false)
//            .submitSurvey(surveyID);
        _surveyDataProvider.fetchSurvey();
        openLink(message.message);
      },
    );
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      //can't launch url, there is some error
    }
  }
}
