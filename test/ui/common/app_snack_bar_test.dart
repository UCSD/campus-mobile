import 'package:campus_mobile_experimental/ui/common/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows and replaces snackbar messages', (WidgetTester tester) async {
    late BuildContext scaffoldContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(snackBarTheme: AppSnackBar.theme),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              scaffoldContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    AppSnackBar.show(scaffoldContext, 'First message');
    await tester.pumpAndSettle();
    expect(find.text('First message'), findsOneWidget);

    AppSnackBar.show(scaffoldContext, 'Second message');
    await tester.pumpAndSettle();
    expect(find.text('First message'), findsNothing);
    expect(find.text('Second message'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('ignores calls with an unmounted context', (WidgetTester tester) async {
    late BuildContext scaffoldContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              scaffoldContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());

    expect(scaffoldContext.mounted, isFalse);
    expect(() => AppSnackBar.show(scaffoldContext, 'Ignored message'), returnsNormally);
    expect(tester.takeException(), isNull);
  });
}
