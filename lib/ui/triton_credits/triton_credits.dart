import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/triton_credits/credit.dart';

const _bodyTextStyle = TextStyle(
  fontFamily: 'Brix Sans',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
  color: Colors.white70,
);

class TritonCredits extends StatelessWidget {
  const TritonCredits({Key? key}) : super(key: key);

  static final List<Credit> _credits = [
    credit(
      feature: 'Triton Credits',
      ideaOwner: 'Kristhian Ortiz Alvarado',
      devName: 'Prisha Jain',
      date: DateTime(2026, 10, 26), // First page implementation: commit 71ca34f4a.
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorPrimary,
    appBar: AppBar(
      titleTextStyle: appBarTitleStyle,
      centerTitle: true,
      elevation: 0,
      backgroundColor: ColorPrimary,
      foregroundColor: lightTextColor,
      title: Text('TRITON CREDITS'),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/UCSDMobile_sharp-removebg-preview.png',
                    fit: BoxFit.contain,
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/UCSanDiego-Logo_White.png',
                    fit: BoxFit.contain,
                    height: 36,
                    width: 200,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'This page is dedicated to the members of our Triton community who helped build and improve the UCSD Campus Mobile app with their ideas, feedback, and/or development skills.',
                  style: _bodyTextStyle,
                ),
                const SizedBox(height: 8),
                const _FeedbackInvitation(),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24, thickness: 1, height: 1),
                const SizedBox(height: 24),
                for (final entry in _credits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: entry.feature,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' was suggested by '),
                          TextSpan(
                            text: entry.ideaOwner,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' and implemented by '),
                          TextSpan(
                            text: entry.devName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' on ${entry.formattedDate}.'),
                        ],
                      ),
                      style: _bodyTextStyle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _FeedbackInvitation extends StatefulWidget {
  const _FeedbackInvitation();

  @override
  State<_FeedbackInvitation> createState() => _FeedbackInvitationState();
}

class _FeedbackInvitationState extends State<_FeedbackInvitation> {
  final _feedbackTap = TapGestureRecognizer()..onTap = () => openLink(SupportConstants.FEEDBACK_URL);

  @override
  void dispose() {
    _feedbackTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(text: 'Have an idea? Submit a feedback ticket to '),
        TextSpan(
          text: 'Feedback & Support',
          style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline),
          recognizer: _feedbackTap,
        ),
        const TextSpan(
          text: ' and you could be immortalized on this page!\nThank you for contributing to your campus mobile app!',
        ),
      ],
    ),
    style: _bodyTextStyle,
  );
}
