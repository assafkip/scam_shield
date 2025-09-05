import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/widgets/companion_widget.dart';

void main() {
  group('CompanionWidget', () {
    testWidgets('displays neutral image for neutral state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanionWidget(state: CompanionState.neutral),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      // You might need a more robust way to check the image asset path
      // For now, just checking if an Image widget is present
    });

    testWidgets('displays happy image for happy state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanionWidget(state: CompanionState.happy),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays concerned image for concerned state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanionWidget(state: CompanionState.concerned),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays sad image for sad state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanionWidget(state: CompanionState.sad),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });
}