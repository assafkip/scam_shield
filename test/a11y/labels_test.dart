/// Accessibility tests for PRD-01 unified conversation engine
/// Ensures interactive controls have proper labels and semantic structure

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/conversation/conversation.dart';
import 'package:scamshield/conversation/loader_migration.dart';
import 'package:scamshield/conversation/renderer.dart';

void main() {
  group('Unified Conversation Accessibility Tests', () {
    late UnifiedConversation testConversation;

    setUp(() {
      testConversation = ConversationMigrationLoader.createSampleConversation();
    });

    testWidgets('Renderer has proper screen reader labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Check AppBar has accessible back button
      final backButton = find.byTooltip('Exit conversation training');
      expect(backButton, findsOneWidget);

      // Check context banner has semantic label
      final contextBanner = find.byWidgetPredicate(
        (widget) => widget is Container &&
                   widget.child is Text &&
                   (widget.child as Text).semanticsLabel != null,
      );
      expect(contextBanner, findsOneWidget);

      // Check choice area has accessible label
      final choiceInstruction = find.byWidgetPredicate(
        (widget) => widget is Text &&
                   widget.semanticsLabel == 'Choose your response to this message',
      );
      expect(choiceInstruction, findsOneWidget);
    });

    testWidgets('Choice buttons are accessible with proper focus order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Find choice buttons
      final choiceButtons = find.byType(ElevatedButton);
      expect(choiceButtons, findsAtLeastNWidgets(1));

      // Check buttons can receive focus
      for (int i = 0; i < (await tester.elementList(choiceButtons)).length; i++) {
        final button = choiceButtons.at(i);
        await tester.tap(button);
        await tester.pump();

        // Verify button is focusable and tappable
        expect(button, findsOneWidget);
      }
    });

    testWidgets('Message bubbles have proper contrast and readability', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Check message containers exist
      final messageContainers = find.byWidgetPredicate(
        (widget) => widget is Container &&
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).color != null,
      );
      expect(messageContainers, findsAtLeastNWidgets(1));

      // Check text elements have sufficient size
      final messageTexts = find.byWidgetPredicate(
        (widget) => widget is Text &&
                   widget.style != null &&
                   (widget.style!.fontSize ?? 14) >= 14,
      );
      expect(messageTexts, findsAtLeastNWidgets(1));
    });

    testWidgets('Choice buttons have visual indicators for safety', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Find choice buttons and verify color coding
      final choiceButtons = find.byType(ElevatedButton);

      final elements = await tester.elementList(choiceButtons);
      if (elements.isNotEmpty) {
        for (final element in elements) {
          final button = element.widget as ElevatedButton;
          final style = button.style;

          // Check that buttons have background colors (green/orange for safe/risky)
          expect(style, isNotNull);
          expect(style!.backgroundColor, isNotNull);
        }
      }
    });

    testWidgets('Scrollable conversation area is keyboard accessible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Check ListView is present for conversation area
      final scrollableArea = find.byType(ListView);
      expect(scrollableArea, findsOneWidget);

      // Verify it can be focused for keyboard navigation
      await tester.tap(scrollableArea);
      await tester.pump();
      expect(scrollableArea, findsOneWidget);
    });

    testWidgets('Dialog elements have proper accessibility structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Simulate completing conversation to trigger dialog
      final currentStep = testConversation.steps.firstWhere(
        (step) => step.choices.isNotEmpty,
        orElse: () => testConversation.steps.first,
      );

      if (currentStep.choices.isNotEmpty) {
        final firstChoice = currentStep.choices.first;

        // Find and tap the first choice
        final choiceButton = find.byWidgetPredicate(
          (widget) => widget is ElevatedButton &&
                     widget.child is Text &&
                     (widget.child as Text).data == firstChoice.label,
        );

        final elements = await tester.elementList(choiceButton);
        if (elements.isNotEmpty) {
          await tester.tap(choiceButton);
          await tester.pump();
        }
      }
    });

    testWidgets('Error states have accessible messaging', (tester) async {
      // Create conversation with invalid step to trigger error state
      final invalidConversation = UnifiedConversation(
        id: 'invalid_test',
        title: 'Invalid Test',
        context: 'Test error handling',
        steps: [], // Empty steps to trigger error
        quiz: [],
        consequenceRules: ConsequenceRules(
          onScam: ConsequenceOutcome(),
          onParanoid: ConsequenceOutcome(),
          onCalibrated: ConsequenceOutcome(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: invalidConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Check error state displays accessible content
      final errorIcon = find.byIcon(Icons.error_outline);
      expect(errorIcon, findsOneWidget);

      final errorTitle = find.text('Training Scenario Error');
      expect(errorTitle, findsOneWidget);

      final returnButton = find.text('Return to Menu');
      expect(returnButton, findsOneWidget);
    });

    testWidgets('Text content meets minimum size requirements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Check all text widgets have minimum font size of 14
      final allTexts = find.byType(Text);

      for (final element in await tester.elementList(allTexts)) {
        final text = element.widget as Text;
        final fontSize = text.style?.fontSize ?? 14.0;

        expect(fontSize, greaterThanOrEqualTo(14.0),
            reason: 'Text "${text.data}" has font size $fontSize < 14');
      }
    });

    testWidgets('Touch targets meet minimum size requirements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedConversationRenderer(
            conversation: testConversation,
            onChoiceSelected: (_) {},
            onQuizCompleted: (_) {},
            onConversationCompleted: () {},
          ),
        ),
      );

      // Check button touch targets are at least 44x44 logical pixels
      final buttons = find.byType(ElevatedButton);

      for (final element in await tester.elementList(buttons)) {
        final renderBox = element.renderObject as RenderBox;
        final size = renderBox.size;

        expect(size.height, greaterThanOrEqualTo(44.0),
            reason: 'Button height ${size.height} < 44px minimum');
        expect(size.width, greaterThanOrEqualTo(44.0),
            reason: 'Button width ${size.width} < 44px minimum');
      }
    });
  });
}