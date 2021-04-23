import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/survey.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyCard extends StatefulWidget {
  SurveyCard();

  @override
  _SurveyCardState createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard>
    with AutomaticKeepAliveClientMixin {
  String cardId = "student_survey";
  double _contentHeight = webViewMinHeight;
  SurveyDataProvider _surveyDataProvider;
  UserDataProvider _userDataProvider;
  bool get wantKeepAlive => true;
  WebViewController _webViewController;
  String surveyIdMessage = "";
  List<String> postMessage;
  String surveyID = "";
  bool displayCard = true;
  String surveyURL;
  bool noActiveSurveys = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _surveyDataProvider = Provider.of<SurveyDataProvider>(context);
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    //super.build(context);
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => {_surveyDataProvider.fetchSurvey()},
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  Widget buildCardContent(BuildContext context) {
    if (_surveyDataProvider.surveyModel.surveyActive == true) {
      surveyURL = _surveyDataProvider.surveyModel.surveyUrl;
      surveyID = _surveyDataProvider.surveyModel.surveyId;
    }

    if (_surveyDataProvider.surveyModel.surveyActive == true &&
        _userDataProvider.userProfileModel.surveyCompletion
            .contains(surveyID)) {
      displayCard = false;
    }

    ///IF NO SURVEYS ARE ACTIVE
    if (surveyURL == null) {
      return Container(
        height: _contentHeight + 50,
        child: Text(
          "No surveys available.\n\nPlease check back later.",
          textAlign: TextAlign.center,
        ),
      );
    }

    if (displayCard == true && surveyURL != null) {
      return Container(
        height: _contentHeight + 50, // Dynamic height iffy, add some padding
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: surveyURL,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _surveyChannel(context),
            _linksChannel(context),
            _heightChannel(context),
          ].toSet(),
        ),
      );
    } else {
      return Container(
        height: _contentHeight + 50,
        child: Text(
          "Thank you for completing the survey.",
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  JavascriptChannel _surveyChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Survey',
      onMessageReceived: (JavascriptMessage message) {
        postMessage = message.message.split("###");
        surveyIdMessage = postMessage[1];
        _surveyDataProvider.submitSurvey(surveyIdMessage);
        _surveyDataProvider.fetchSurvey();
      },
    );
  }

  JavascriptChannel _linksChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'OpenLink',
      onMessageReceived: (JavascriptMessage message) {
        openLink(message.message);
      },
    );
  }

  JavascriptChannel _heightChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'SetHeight',
      onMessageReceived: (JavascriptMessage message) {
        setState(() {
          _contentHeight =
              validateHeight(context, double.tryParse(message.message));
        });
      },
    );
  }
}
