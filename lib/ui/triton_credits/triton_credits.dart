import 'package:flutter/material.dart';
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
  const TritonCredits({Key? key, this.credits}) : super(key: key);

  final List<Credit>? credits;

  static final List<Credit> _credits = [
    credit(
      feature: 'Triton Credits',
      ideaOwner: 'Kristhian Ortiz',
      devName: 'Prisha Jain',
      date: DateTime(2026, 10, 2),
    ),
    credit(
      feature: 'Show Waitlisted Classes',
      ideaOwner: 'Saeli Yuki',
      devName: 'Gibson Connor',
      date: DateTime(2026, 10, 24), // First implementation: commit c243436b3.
    ),
  ];

  List<Credit> get _sortedCredits {
    final entries = (credits ?? _credits).indexed.toList();
    entries.sort((a, b) {
      final byDate = DateUtils.dateOnly(b.$2.date).compareTo(DateUtils.dateOnly(a.$2.date));
      return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
    });
    return entries.map((entry) => entry.$2).toList();
  }

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
                Semantics(
                  header: true,
                  child: Text(
                    'UCSD Campus Mobile App Contributions',
                    textAlign: TextAlign.center,
                    style: _bodyTextStyle.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                for (final (index, entry) in _sortedCredits.indexed) ...[
                  if (index > 0) const _CreditSeparator(),
                  Text.rich(
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
                ],
                const SizedBox(height: 24),
                const Text('Thank you for contributing to your campus mobile app!', style: _bodyTextStyle),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

const _separatorDot = SizedBox(
  width: 4,
  height: 4,
  child: DecoratedBox(
    decoration: BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
  ),
);

class _CreditSeparator extends StatelessWidget {
  const _CreditSeparator();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _separatorDot,
            const SizedBox(width: 6),
            _separatorDot,
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/UCSDMobile_sharp-removebg-preview.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            _separatorDot,
            const SizedBox(width: 6),
            _separatorDot,
          ],
        ),
      ),
    ),
  );
}

class _FeedbackInvitation extends StatelessWidget {
  const _FeedbackInvitation();

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: InkWell(
      onTap: () => openLink(SupportConstants.FEEDBACK_URL),
      borderRadius: BorderRadius.circular(6),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused)) {
          return Colors.white12;
        }
        if (states.contains(WidgetState.hovered)) return Colors.white10;
        return Colors.transparent;
      }),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Have an idea? Submit a feedback ticket to '),
                TextSpan(
                  text: 'Feedback & Support',
                  style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                ),
                TextSpan(text: ' and you could be immortalized on this page!'),
              ],
            ),
            style: _bodyTextStyle,
          ),
        ),
      ),
    ),
  );
}
