import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/survey_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/util/webview.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
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
  double _contentHeight = cardContentMinHeight;
  SurveyDataProvider _surveyDataProvider;
  UserDataProvider _userDataProvider;
  WebViewController _webViewController;
  List<String> postMessage;
  String surveyID;
//  bool hasSubmitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _surveyDataProvider = Provider.of<SurveyDataProvider>(context);
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
//    } else {
//      return Container();
//    }
  }

//  final _url = "https://cwo-test.ucsd.edu/WebCards/sample_survey.html";
  final _url = "https://cwo-test.ucsd.edu/WebCards/student_survey.html";
//  final _url =
//      "https://mobile.ucsd.edu/replatform/v1/qa/webview/student_survey.html";

  Widget buildCardContent(BuildContext context) {
//    return Container(
//        child: Column(
//      children: [
//        Text(activeStatusModel.toString()),
//        Text(surveyIdModel.toString()),
//        Text(surveyUrlModel),
//      ],
//    ));
    _surveyDataProvider.surveyModels.forEach((survey) {
      print("survey active in buildcardcontent: " +
          survey.surveyActive.toString());
      if (survey.surveyActive == false) {
        return buildSubmissionCardContent(context);
      }
    });

    return Container(
      height: _contentHeight + 50,
      child: WebView(
        opaque: false,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: _url,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        javascriptChannels: <JavascriptChannel>[
          _printJavascriptChannel(context),
        ].toSet(),
        onPageFinished: (_) async {
          await _updateContentHeight('');
        },
      ),
    );
  }

  Widget buildSubmissionCardContent(BuildContext context) {
    return Container(
      height: _contentHeight + 50,
      child: Text("Thank you for submitting this form!"),
    );
  }

  JavascriptChannel _printJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'CampusMobile',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
        postMessage = message.message.split("###");
        surveyID = postMessage[1];
        print(postMessage[1]);
        Provider.of<SurveyDataProvider>(context, listen: false)
            .submitSurvey(surveyID);
        _surveyDataProvider.fetchSurvey();
        openLink(message.message);
      },
    );
  }

  Future<void> _updateContentHeight(String some) async {
    var newHeight =
        await getNewContentHeight(_webViewController, _contentHeight);
    if (newHeight != _contentHeight) {
      setState(() {
        _contentHeight = newHeight;
      });
    }
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      //can't launch url, there is some error
    }
  }
}
