
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/training/engine.dart';
import 'package:scamshield/training/scenarios.dart';
import 'package:scamshield/screens/training_screen.dart'; // Import TrainingScreen for widget test

void main() {
  group('TrainingEngine', () {
    late TrainingEngine engine;

    setUp(() {
      engine = TrainingEngine(scenarios: trainingScenarios);
    });

    test('initial state is scenario', () {
      expect(engine.state, TrainingState.scenario);
    });

    test('starts with the first scenario', () {
      expect(engine.getCurrentScenario().id, 'courier_duty');
    });

    test('making a choice transitions to feedback state', () {
      engine.makeChoice('pay_fee');
      expect(engine.state, TrainingState.feedback);
      expect(engine.lastChoice?.id, 'pay_fee');
    });

    test('next from feedback transitions to debrief', () {
      engine.makeChoice('pay_fee');
      engine.next();
      expect(engine.state, TrainingState.debrief);
    });

    test('next from debrief transitions to recall', () {
      engine.makeChoice('pay_fee');
      engine.next(); // feedback -> debrief
      engine.next(); // debrief -> recall
      expect(engine.state, TrainingState.recall);
    });

    test('answering recall question returns correct result', () {
      engine.makeChoice('pay_fee');
      engine.next(); // feedback -> debrief
      engine.next(); // debrief -> recall
      final question = engine.getCurrentRecallQuestion();
      expect(engine.answerRecallQuestion(question.correctAnswerId), isTrue);
      expect(engine.answerRecallQuestion('wrong_id'), isFalse);
    });

    test('next from recall transitions to next scenario or completed', () {
      engine.makeChoice('pay_fee');
      engine.next(); // feedback -> debrief
      engine.next(); // debrief -> recall
      engine.next(); // recall -> next scenario or completed

      if (trainingScenarios.length > 1) {
        expect(engine.state, TrainingState.scenario);
        expect(engine.getCurrentScenario().id, isNot('courier_duty'));
      } else {
        expect(engine.state, TrainingState.completed);
      }
    });

    test('full flow through one scenario', () {
      expect(engine.state, TrainingState.scenario);
      expect(engine.getCurrentScenario().id, 'courier_duty');

      engine.makeChoice('ignore');
      expect(engine.state, TrainingState.feedback);
      expect(engine.lastChoice?.feedback.isCorrect, isTrue);

      engine.next();
      expect(engine.state, TrainingState.debrief);

      engine.next();
      expect(engine.state, TrainingState.recall);
      expect(engine.getCurrentRecallQuestion().id, 'q1');

      final isCorrect = engine.answerRecallQuestion('a1');
      expect(isCorrect, isTrue);

      engine.next();
      if (trainingScenarios.length > 1) {
        expect(engine.state, TrainingState.scenario);
      } else {
        expect(engine.state, TrainingState.completed);
      }
    });

    test('content integrity: unique ids', () {
      final scenarioIds = trainingScenarios.map((s) => s.id).toSet();
      expect(scenarioIds.length, trainingScenarios.length);

      for (final scenario in trainingScenarios) {
        final choiceIds = scenario.choices.map((c) => c.id).toSet();
        expect(choiceIds.length, scenario.choices.length);

        final questionIds = scenario.recallQuestions.map((q) => q.id).toSet();
        expect(questionIds.length, scenario.recallQuestions.length);

        for (final question in scenario.recallQuestions) {
          final answerIds = question.answers.map((a) => a.id).toSet();
          expect(answerIds.length, question.answers.length);
        }
      }
    });

    test('content integrity: each scenario has >= 2 choices', () {
      for (final scenario in trainingScenarios) {
        expect(scenario.choices.length, greaterThanOrEqualTo(2));
      }
    });

    // Widget test for badge dialog selection logic
    testWidgets('badge dialog appears with correct badge on scenario completion', (tester) async {
      // Pump the TrainingScreen
      await tester.pumpWidget(const MaterialApp(home: TrainingScreen()));
      await tester.pumpAndSettle(); // Wait for initial build

      // Make a correct choice for the first scenario
      await tester.tap(find.text('Ignore the message.')); // Assuming this is the correct choice for courier_duty
      await tester.pumpAndSettle(); // Wait for feedback to appear

      // Continue to debrief
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(); // Wait for debrief to appear

      // Continue to recall question
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(); // Wait for recall question to appear

      // Answer recall question correctly
      await tester.tap(find.text('A request for payment via a link.')); // Assuming this is the correct answer
      await tester.pumpAndSettle(); // Wait for snackbar and next state

      // Now the badge dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Scenario Completed!'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Check for badge image
      // Verify the specific badge image (e.g., gold, star)
      // For the 'courier_duty' scenario, if both choice and recall are correct, it should be a Star Badge.
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/badge_star.png'), findsOneWidget);

      // Tap OK to dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}
