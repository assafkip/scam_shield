import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/widgets/companion_widget.dart';

void main() {
  group('CompanionWidget', () {
    testWidgets('displays neutral state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CompanionWidget(state: CompanionState.neutral)),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
    });

    testWidgets('displays happy state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CompanionWidget(state: CompanionState.happy)),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Happy'), findsOneWidget);
    });

    testWidgets('displays concerned state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanionWidget(state: CompanionState.concerned),
          ),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Concerned'), findsOneWidget);
    });

    testWidgets('displays sad state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CompanionWidget(state: CompanionState.sad)),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Sad'), findsOneWidget);
    });
  });
}
