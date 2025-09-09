import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/content/loader.dart';
import 'package:scamshield/training/engine.dart';
import 'package:scamshield/content/schema.dart'; // Import schema for Scenario

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Youth Scenario Flow', () {
    late List<Scenario> youthScenarios;

    setUpAll(() async {
      // Load all scenarios and filter for youth-focused ones
      final allScenarios = await ContentLoader.loadScenarios();
      youthScenarios = allScenarios.where((s) => s.id.startsWith('y0')).toList();
    });

    test('y01_dating scenario plays through golden path', () async {
      final datingScenario = youthScenarios.firstWhere((s) => s.id == 'y01_dating');
      final engine = TrainingEngine(scenarios: [datingScenario]);

      // Step 1: Initial message
      expect(engine.state, TrainingState.scenario);
      expect(engine.getCurrentScenario().id, 'y01_dating');
      expect(engine.getCurrentStep().type, StepType.message);
      
      // Move to choice step
      engine.next();
      expect(engine.state, TrainingState.scenario);
      expect(engine.getCurrentStep().type, StepType.choice);

      // Step 2: Choice - suggest video call (safe choice)
      final chosenOption = engine.makeChoice('suggest_video'); // "Suggest a quick video call instead" (safe)
      expect(engine.state, TrainingState.feedback);
      expect(chosenOption.isSafe, isTrue); // Check if the chosen option was safe
      engine.next(); // Move to debrief
      expect(engine.state, TrainingState.debrief);
      engine.next(); // Move to recall
      expect(engine.state, TrainingState.recall);

      // Step 3: Recall Quiz - first question
      final quizItem1 = engine.getCurrentRecallQuestion();
      expect(quizItem1.id, 'recall_1');
      engine.answerRecallQuestion(quizItem1.correctAnswerId); // Answer correctly
      engine.next(); // Move to next recall question

      expect(engine.state, TrainingState.recall); // Still in recall for second question
      
      // Step 4: Recall Quiz - second question
      final quizItem2 = engine.getCurrentRecallQuestion();
      expect(quizItem2.id, 'recall_2');
      engine.answerRecallQuestion(quizItem2.correctAnswerId); // Answer correctly
      engine.next(); // Move to completed

      expect(engine.state, TrainingState.completed); // Only one scenario in engine
    });

    // Add more tests for other youth scenarios if needed, following golden path
    // For example:
    // test('y02_sextortion scenario plays through golden path', () async { ... });
    // test('y03_crypto scenario plays through golden path', () async { ... });
  });
}
