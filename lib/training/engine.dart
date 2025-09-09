import 'package:scamshield/content/schema.dart';

enum TrainingState {
  scenario,
  feedback,
  debrief,
  recall,
  completed,
}

enum BadgeType {
  none,
  bronze,
  silver,
  gold,
  star,
}

class TrainingEngine {
  final List<Scenario> scenarios;
  int _currentScenarioIndex = 0;
  int _currentStepIndex = 0;
  int _currentRecallQuestionIndex = 0;
  TrainingState _state = TrainingState.scenario;

  int _correctChoicesInScenario = 0;
  int _correctRecallAnswersInScenario = 0;

  TrainingEngine({required this.scenarios});

  TrainingState get state => _state;

  Scenario getCurrentScenario() {
    return scenarios[_currentScenarioIndex];
  }

  ScenarioStep getCurrentStep() {
    return getCurrentScenario().steps[_currentStepIndex];
  }

  StepChoice makeChoice(String choiceId) { // Changed return type to StepChoice
    if (_state != TrainingState.scenario) throw StateError('Invalid state for making a choice.'); // Added throw

    final currentStep = getCurrentStep();
    final chosenOption = currentStep.choices!.firstWhere((c) => c.id == choiceId);

    if (chosenOption.isSafe) {
      _correctChoicesInScenario++;
    }

    // Find the next step which is the debrief for this choice
    // Assuming debrief step immediately follows the choice step in the JSON
    _currentStepIndex++; // Move to the debrief step
    _state = TrainingState.feedback;
    return chosenOption; // Return the chosen option
  }

  void next() {
    final currentScenario = getCurrentScenario();

    if (_state == TrainingState.scenario) {
      // Handle message steps - advance to next step
      final currentStep = getCurrentStep();
      if (currentStep.type == StepType.message) {
        _currentStepIndex++;
        // Stay in scenario state for the next step
      }
    } else if (_state == TrainingState.feedback) {
      _currentStepIndex++; // Move past the debrief step
      _state = TrainingState.debrief;
    } else if (_state == TrainingState.debrief) {
      // Check if there are more steps in the current scenario
      if (_currentStepIndex < currentScenario.steps.length) {
        final nextStep = currentScenario.steps[_currentStepIndex];
        if (nextStep.type == StepType.quiz) { // Assuming quiz is a step type now
          _state = TrainingState.recall;
          _currentRecallQuestionIndex = 0;
        } else {
          _state = TrainingState.scenario; // Move to next message/choice step
        }
      } else { // No more steps, go to quiz or next scenario
        _state = TrainingState.recall;
        _currentRecallQuestionIndex = 0;
      }
    } else if (_state == TrainingState.recall) {
      if (_currentRecallQuestionIndex < currentScenario.quiz.items.length - 1) {
        _currentRecallQuestionIndex++;
      } else {
        // Quiz completed, move to next scenario or overall completion
        if (_currentScenarioIndex < scenarios.length - 1) {
          _currentScenarioIndex++;
          _state = TrainingState.scenario;
          _currentStepIndex = 0; // Reset step index for new scenario
          _resetScenarioProgress();
        } else {
          _state = TrainingState.completed;
        }
      }
    }
  }

  QuizItem getCurrentRecallQuestion() {
    return getCurrentScenario().quiz.items[_currentRecallQuestionIndex];
  }

  bool answerRecallQuestion(String answerId) {
    final question = getCurrentRecallQuestion();
    final isCorrect = question.correctAnswerId == answerId;
    if (isCorrect) {
      _correctRecallAnswersInScenario++;
    }
    return isCorrect;
  }

  BadgeType getBadgeForCurrentScenario() {
    final scenario = getCurrentScenario();
    // Assuming each scenario has at least one choice step and one quiz item
    final totalSafeChoices = scenario.steps
        .where((step) => step.type == StepType.choice)
        .expand((step) => step.choices!)
        .where((choice) => choice.isSafe)
        .length;
    final totalQuizItems = scenario.quiz.items.length;

    if (totalSafeChoices == 0 && totalQuizItems == 0) {
      return BadgeType.none;
    }

    final choicePercentage = totalSafeChoices > 0 ? (_correctChoicesInScenario / totalSafeChoices) : 1.0;
    final recallPercentage = totalQuizItems > 0 ? (_correctRecallAnswersInScenario / totalQuizItems) : 1.0;

    if (recallPercentage == 1.0 && choicePercentage == 1.0) { // Corrected condition
      return BadgeType.star;
    } else if (choicePercentage >= 0.75) {
      return BadgeType.gold;
    } else if (choicePercentage >= 0.5) {
      return BadgeType.silver;
    } else if (choicePercentage >= 0.25) {
      return BadgeType.bronze;
    } else {
      return BadgeType.none;
    }
  }

  void _resetScenarioProgress() {
    _correctChoicesInScenario = 0;
    _correctRecallAnswersInScenario = 0;
  }
}
