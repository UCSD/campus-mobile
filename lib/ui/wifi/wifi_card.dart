import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/speed_test.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';

class WiFiCard extends StatelessWidget {
  const WiFiCard({super.key});

  final String cardId = "speed_test";

  @override
  Widget build(BuildContext context) => Consumer<SpeedTestProvider>(
    builder: (context, speedTestProvider, _) {
      final isRunning = speedTestProvider.state is SpeedTestRunning;
      return CardContainer(
        cardId: cardId,
        active: context.select((CardsDataProvider provider) => provider.cardStates[cardId] ?? false),
        hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
        reload: () {
          if (!isRunning) speedTestProvider.init();
        },
        isLoading: speedTestProvider.isLoading,
        titleText: CardTitleConstants.TITLE_MAP[cardId]!,
        errorText: null,
        child: () => _buildCardContent(context, speedTestProvider),
      );
    },
  );

  Widget _buildCardContent(BuildContext context, SpeedTestProvider speedTestProvider) => Padding(
    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
    child: _buildStateWidget(context, speedTestProvider),
  );

  Widget _buildStateWidget(BuildContext context, SpeedTestProvider speedTestProvider) {
    final state = speedTestProvider.state;
    if (state is SpeedTestRunning) return _speedTest(context, state);
    if (state is SpeedTestSuccess) return _finishedState(context, speedTestProvider, state);
    if (state is SpeedTestTimeout) return _timeoutState(context, speedTestProvider, state);
    if (state is SpeedTestUnavailable) return _unavailableState(speedTestProvider);
    if (state is SpeedTestSimulated) return _simulatedState();
    if (state is SpeedTestFailure) return _errorState(speedTestProvider);
    return _initialState(context, speedTestProvider);
  }

  Column _initialState(BuildContext context, SpeedTestProvider speedTestProvider) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.wifi_sharp,
            color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
            size: 38,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Help identify campus WiFi issues.",
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).brightness == Brightness.light
                      ? descriptiveTextColorLight
                      : descriptiveTextColorDark,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 50),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionButton(
            buttonText: 'TEST SPEED',
            onPressed: () {
              analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'test_speed'});
              speedTestProvider.startSpeedTest();
            },
          ),
          ActionLink(
            buttonText: 'REPORT ISSUE',
            onPressed: () {
              analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'report_issue'});
              _showReportDialog(context, speedTestProvider, success: false);
            },
          ),
        ],
      ),
    ],
  );

  Column _speedTest(BuildContext context, SpeedTestRunning state) {
    final label = state.phase == SpeedTestPhase.upload ? "Testing upload... " : "Testing download... ";
    final progress = _safeProgress(state.overallProgress);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 28),
                ),
                WidgetSpan(child: Icon(Icons.wifi, size: 28)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: LiquidLinearProgressIndicator(
            backgroundColor: Colors.white,
            borderColor: Colors.black,
            borderWidth: 0.5,
            center: Text(_formatProgress(progress), style: TextStyle(color: Colors.grey)),
            direction: Axis.horizontal,
            value: progress,
            valueColor: AlwaysStoppedAnimation(lightPrimaryColor),
          ),
        ),
      ],
    );
  }

  Column _finishedState(BuildContext context, SpeedTestProvider speedTestProvider, SpeedTestSuccess state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _speedRow(context, 'Download speed:', _formatSpeed(state.downloadMbps)),
      SizedBox(height: 20),
      _speedRow(context, 'Upload speed:', _formatSpeed(state.uploadMbps)),
      SizedBox(height: 20),
      _actionRow(context, speedTestProvider, reportSuccess: true),
    ],
  );

  Column _timeoutState(BuildContext context, SpeedTestProvider speedTestProvider, SpeedTestTimeout state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _speedRow(
        context,
        'Download speed:',
        state.downloadCompleted ? _formatSpeed(state.downloadMbps) : 'N/A (Timed Out)',
      ),
      SizedBox(height: 20),
      _speedRow(context, 'Upload speed:', 'N/A (Timed Out)'),
      SizedBox(height: 20),
      _actionRow(context, speedTestProvider, reportSuccess: false),
    ],
  );

  Row _actionRow(BuildContext context, SpeedTestProvider speedTestProvider, {required bool reportSuccess}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ActionButton(
        buttonText: 'TEST SPEED',
        onPressed: () {
          analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'test_speed'});
          speedTestProvider.startSpeedTest();
        },
      ),
      SizedBox(width: 10),
      ActionLink(
        buttonText: 'REPORT ISSUE',
        onPressed: () {
          analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'report_issue'});
          _showReportDialog(context, speedTestProvider, success: reportSuccess);
        },
      ),
    ],
  );

  Padding _speedRow(BuildContext context, String label, String value) => Padding(
    padding: EdgeInsets.only(left: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 26,
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
            ),
          ),
        ),
      ],
    ),
  );

  Column _unavailableState(SpeedTestProvider speedTestProvider) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Text("Connect to a UCSD Network", style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
      ),
      SizedBox(height: 50),
      ActionButton(
        buttonText: 'TRY AGAIN',
        onPressed: () {
          analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'try_again'});
          speedTestProvider.init();
        },
      ),
    ],
  );

  Column _simulatedState() => Column(
    children: [
      Padding(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Text("Sorry", style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Text(
          "This feature is only available on physical devices.",
          style: TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );

  Column _errorState(SpeedTestProvider speedTestProvider) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Text("Unable to complete the speed test.", style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
      ),
      SizedBox(height: 50),
      ActionButton(
        buttonText: 'TRY AGAIN',
        onPressed: () {
          analytics.logEvent(name: '${cardId}_card_action', parameters: {'action': 'try_again'});
          speedTestProvider.init();
        },
      ),
    ],
  );

  void _showReportDialog(BuildContext context, SpeedTestProvider speedTestProvider, {required bool success}) {
    speedTestProvider.reportIssue();
    showDialog(
      context: context,
      builder: (context) => AlertDialogWidget(
        type: success ? MessageTypeConstants.SUCCESS : MessageTypeConstants.ERROR,
        icon: success ? Icons.check_circle_outline_sharp : Icons.block_flipped,
        title: success ? WifiConstants.WIFI_ISSUE_SUCCESS_TITLE : WifiConstants.WIFI_ISSUE_FAILED_TITLE,
        description: success ? WifiConstants.WIFI_ISSUE_SUCCESS_DESC : WifiConstants.WIFI_ISSUE_FAILED_DESC,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  String _formatProgress(double progress) => '${(progress * 100).toStringAsFixed(1)} %';

  String _formatSpeed(double speed) => speed.isFinite ? '${speed.toStringAsPrecision(3)} Mbps' : 'N/A';

  double _safeProgress(double progress) => progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;
}

class ScalingUtility {
  late MediaQueryData _queryData;
  static late double horizontalSafeBlock;
  static double? verticalSafeBlock;

  void getCurrentMeasurements(BuildContext context) {
    _queryData = MediaQuery.of(context);
    horizontalSafeBlock = (_queryData.size.width - (_queryData.padding.left + _queryData.padding.right)) / 100;
    verticalSafeBlock = (_queryData.size.height - (_queryData.padding.top + _queryData.padding.bottom)) / 100;
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
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
