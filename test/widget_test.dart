import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/main.dart';

void main() {
  testWidgets('Analyzes text and displays results', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScamShieldApp());

    // Verify that the initial UI is correct.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    // Enter text into the TextField.
    await tester.enterText(find.byType(TextField), 'This is a test message');

    // Tap the analyze button.
    await tester.tap(find.text('Analyze'));
    await tester.pump();

    // Verify that the results are displayed.
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
  });
}