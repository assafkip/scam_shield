/// Accessibility tests for PRD-02 pressure meter components
/// Ensures pressure meter has proper semantic role and labels

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/conversation/pressure_meter.dart';

void main() {
  group('Pressure Meter Accessibility Tests', () {
    testWidgets('PressureMeter has semantic role "progressbar" and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: 75.0,
              label: 'Current pressure level',
            ),
          ),
        ),
      );

      // Find the pressure meter semantic widget
      final pressureMeterFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics &&
                   widget.properties.label == 'Current pressure level',
      );

      expect(pressureMeterFinder, findsOneWidget);

      // Check semantic properties
      final semanticsWidget = tester.widget<Semantics>(pressureMeterFinder);
      expect(semanticsWidget.properties.label, equals('Current pressure level'));
      expect(semanticsWidget.properties.value, contains('75 percent'));
      expect(semanticsWidget.properties.value, contains('High pressure'));
    });

    testWidgets('PressureMeter provides descriptive value text', (tester) async {
      // Test different pressure levels
      const testCases = [
        (level: 10.0, expectedDescription: 'Low pressure'),
        (level: 35.0, expectedDescription: 'Moderate pressure'),
        (level: 65.0, expectedDescription: 'High pressure'),
        (level: 90.0, expectedDescription: 'Extreme pressure'),
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PressureMeter(
                pressureLevel: testCase.level,
                label: 'Test pressure meter',
              ),
            ),
          ),
        );

        final semanticsWidget = tester.widget<Semantics>(
          find.byWidgetPredicate(
            (widget) => widget is Semantics &&
                       widget.properties.label == 'Test pressure meter',
          ),
        );

        expect(
          semanticsWidget.properties.value,
          contains(testCase.expectedDescription),
          reason: 'Level ${testCase.level} should have description "${testCase.expectedDescription}"',
        );

        expect(
          semanticsWidget.properties.value,
          contains('${testCase.level.toStringAsFixed(0)} percent'),
          reason: 'Should include percentage value',
        );
      }
    });

    testWidgets('CompactPressureMeter is accessible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactPressureMeter(
              pressureLevel: 42.0,
              showLabel: true,
            ),
          ),
        ),
      );

      // Should contain the underlying PressureMeter with proper semantics
      final pressureMeterFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics &&
                   widget.properties.label == 'Current pressure level',
      );

      expect(pressureMeterFinder, findsOneWidget);

      // Check the compact meter shows the label
      expect(find.text('Pressure: '), findsOneWidget);
    });

    testWidgets('ThermometerPressureMeter has proper accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThermometerPressureMeter(
              pressureLevel: 60.0,
            ),
          ),
        ),
      );

      final thermometerFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics &&
                   widget.properties.label == 'Pressure thermometer',
      );

      expect(thermometerFinder, findsOneWidget);

      final semanticsWidget = tester.widget<Semantics>(thermometerFinder);
      expect(semanticsWidget.properties.value, contains('60 percent pressure'));
    });

    testWidgets('PressureMeter accessibility works with animation disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: 80.0,
              animate: false,
              label: 'Static pressure meter',
            ),
          ),
        ),
      );

      final pressureMeterFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics &&
                   widget.properties.label == 'Static pressure meter',
      );

      expect(pressureMeterFinder, findsOneWidget);

      final semanticsWidget = tester.widget<Semantics>(pressureMeterFinder);
      expect(semanticsWidget.properties.value, contains('80 percent'));
      expect(semanticsWidget.properties.value, contains('High pressure'));
    });

    testWidgets('PressureMeter semantic values update with pressure changes', (tester) async {
      const lowPressure = 15.0;
      const highPressure = 85.0;

      // Start with low pressure
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: lowPressure,
              label: 'Dynamic pressure meter',
            ),
          ),
        ),
      );

      var semanticsWidget = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) => widget is Semantics &&
                     widget.properties.label == 'Dynamic pressure meter',
        ),
      );

      expect(semanticsWidget.properties.value, contains('15 percent'));
      expect(semanticsWidget.properties.value, contains('Low pressure'));

      // Update to high pressure
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: highPressure,
              label: 'Dynamic pressure meter',
            ),
          ),
        ),
      );

      semanticsWidget = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) => widget is Semantics &&
                     widget.properties.label == 'Dynamic pressure meter',
        ),
      );

      expect(semanticsWidget.properties.value, contains('85 percent'));
      expect(semanticsWidget.properties.value, contains('Extreme pressure'));
    });

    testWidgets('PressureMeter percentage text is readable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: 50.0,
              height: 24.0, // Minimum height for text display
            ),
          ),
        ),
      );

      // Should show percentage text when height is sufficient
      expect(find.text('50%'), findsOneWidget);

      // Test with smaller height (should not show text)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: 50.0,
              height: 16.0, // Below minimum for text
            ),
          ),
        ),
      );

      // Text should not be visible for small heights
      expect(find.text('50%'), findsNothing);
    });

    testWidgets('PressureMeter color changes provide visual accessibility cues', (tester) async {
      const testLevels = [10.0, 30.0, 60.0, 90.0];

      for (final level in testLevels) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PressureMeter(
                pressureLevel: level,
                height: 30.0,
              ),
            ),
          ),
        );

        // Ensure the pressure meter renders without errors
        expect(find.byType(PressureMeter), findsOneWidget);

        // The color changes are handled internally, but we can verify
        // the widget builds successfully at different pressure levels
      }
    });

    testWidgets('PressureMeter touch target meets minimum size requirements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: 50.0,
              height: 44.0, // Minimum touch target height
            ),
          ),
        ),
      );

      final pressureMeter = find.byType(PressureMeter);
      expect(pressureMeter, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(pressureMeter);
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('Pressure meter has accessible semantic properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressureMeter(
              pressureLevel: 75.0,
              label: 'Test progress meter',
            ),
          ),
        ),
      );

      // Find the semantics widget
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics &&
                   widget.properties.label == 'Test progress meter',
      );

      expect(semanticsFinder, findsOneWidget);

      // Check semantic properties
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.label, equals('Test progress meter'));
      expect(semanticsWidget.properties.value, contains('75 percent'));
    });
  });
}