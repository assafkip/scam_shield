
import 'scenarios.dart';

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
  final List<TrainingScenario> scenarios;
  int _currentScenarioIndex = 0;
  int _currentRecallQuestionIndex = 0;
  TrainingState _state = TrainingState.scenario;
  ScenarioChoice? _lastChoice;

  int _correctChoicesInScenario = 0;
  int _correctRecallAnswersInScenario = 0;

  TrainingEngine({required this.scenarios});

  TrainingState get state => _state;

  TrainingScenario getCurrentScenario() {
    return scenarios[_currentScenarioIndex];
  }

  ScenarioChoice? get lastChoice => _lastChoice;

  void makeChoice(String choiceId) {
    if (_state != TrainingState.scenario) return;

    final scenario = getCurrentScenario();
    _lastChoice = scenario.choices.firstWhere((c) => c.id == choiceId);
    if (_lastChoice!.feedback.isCorrect) {
      _correctChoicesInScenario++;
    }
    _state = TrainingState.feedback;
  }

  void next() {
    if (_state == TrainingState.feedback) {
      _state = TrainingState.debrief;
    } else if (_state == TrainingState.debrief) {
      _state = TrainingState.recall;
      _currentRecallQuestionIndex = 0;
    } else if (_state == TrainingState.recall) {
      final scenario = getCurrentScenario();
      if (_currentRecallQuestionIndex < scenario.recallQuestions.length - 1) {
        _currentRecallQuestionIndex++;
      } else {
        // Scenario completed
        if (_currentScenarioIndex < scenarios.length - 1) {
          _currentScenarioIndex++;
          _state = TrainingState.scenario;
          _resetScenarioProgress();
        } else {
          _state = TrainingState.completed;
        }
      }
    }
  }

  RecallQuestion getCurrentRecallQuestion() {
    return getCurrentScenario().recallQuestions[_currentRecallQuestionIndex];
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
    final totalChoices = scenario.choices.length;
    final totalRecallQuestions = scenario.recallQuestions.length;

    if (totalChoices == 0 && totalRecallQuestions == 0) {
      return BadgeType.none;
    }

    final choicePercentage = totalChoices > 0 ? (_correctChoicesInScenario / totalChoices) : 1.0;
    final recallPercentage = totalRecallQuestions > 0 ? (_correctRecallAnswersInScenario / totalRecallQuestions) : 1.0;

    if (recallPercentage == 1.0 && choicePercentage == 1.0) {
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

