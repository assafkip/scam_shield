import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/training/engine.dart';
import 'package:scamshield/content/schema.dart'; // Import schema for Scenario
import 'package:scamshield/content/loader.dart'; // Import ContentLoader

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TrainingEngine', () {
    late TrainingEngine engine;
    late List<Scenario> loadedScenarios;

    setUpAll(() async { // Use setUpAll for async initialization
      loadedScenarios = await ContentLoader.loadScenarios();
    });

    setUp(() {
      engine = TrainingEngine(scenarios: loadedScenarios);
    });

    test('initial state is scenario', () {
      expect(engine.state, TrainingState.scenario);
    });

    test('starts with the first scenario', () {
      expect(engine.getCurrentScenario().id, 'courier_duty');
    });

    test('making a choice transitions to feedback state', () {
      final chosenOption = engine.makeChoice('pay_fee');
      expect(engine.state, TrainingState.feedback);
      // Access the chosen option from the current step
      expect(chosenOption.id, 'pay_fee');
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

      if (loadedScenarios.length > 1) { // Use loadedScenarios
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
      // Check if the chosen option was safe
      final chosenOption = engine.makeChoice('ignore'); // Re-call makeChoice to get the returned option
      expect(chosenOption.isSafe, isTrue);

      engine.next();
      expect(engine.state, TrainingState.debrief);

      engine.next();
      expect(engine.state, TrainingState.recall);
      expect(engine.getCurrentRecallQuestion().id, 'q1');

      final isCorrect = engine.answerRecallQuestion('a1');
      expect(isCorrect, isTrue);

      engine.next();
      if (loadedScenarios.length > 1) { // Use loadedScenarios
        expect(engine.state, TrainingState.scenario);
      } else {
        expect(engine.state, TrainingState.completed);
      }
    });

    test('content integrity: unique ids', () {
      final scenarioIds = loadedScenarios.map((s) => s.id).toSet(); // Use loadedScenarios
      expect(scenarioIds.length, loadedScenarios.length); // Use loadedScenarios

      for (final scenario in loadedScenarios) { // Use loadedScenarios
        // Check step IDs
        final stepIds = scenario.steps.map((step) => step.id).toSet();
        expect(stepIds.length, scenario.steps.length);

        for (final step in scenario.steps) {
          if (step.type == StepType.choice) {
            final choiceIds = step.choices!.map((c) => c.id).toSet();
            expect(choiceIds.length, step.choices!.length);
          }
        }

        // Check quiz item IDs
        final quizItemIds = scenario.quiz.items.map((item) => item.id).toSet();
        expect(quizItemIds.length, scenario.quiz.items.length);

        for (final quizItem in scenario.quiz.items) {
          final optionIds = quizItem.options.map((option) => option.id).toSet();
          expect(optionIds.length, quizItem.options.length);
        }
      }
    });

    test('content integrity: each scenario has >= 2 choices', () {
      for (final scenario in loadedScenarios) { // Use loadedScenarios
        final choiceSteps = scenario.steps.where((step) => step.type == StepType.choice).toList();
        expect(choiceSteps.isNotEmpty, isTrue); // Ensure there's at least one choice step
        for (final choiceStep in choiceSteps) {
          expect(choiceStep.choices!.length, greaterThanOrEqualTo(2));
        }
      }
    });

    /*
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
      await tester.pumpAndSettle(); // Add this line to wait for the dialog to render
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Scenario Completed!'), findsOneWidget);
      // expect(find.byType(Image), findsOneWidget); // Check for badge image
      // Verify the specific badge image (e.g., gold, star)
      // For the 'courier_duty' scenario, if both choice and recall are correct, it should be a Star Badge.
      // expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/badge_star.png'), findsOneWidget);

      // Tap OK to dismiss dialog
      // await tester.tap(find.text('OK'));
      // await tester.pumpAndSettle();
    });
    */
  });
}
