
import 'scenarios.dart';

enum TrainingState {
  scenario,
  feedback,
  debrief,
  recall,
  completed,
}

class TrainingEngine {
  final List<TrainingScenario> scenarios;
  int _currentScenarioIndex = 0;
  int _currentRecallQuestionIndex = 0;
  TrainingState _state = TrainingState.scenario;
  ScenarioChoice? _lastChoice;

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
        if (_currentScenarioIndex < scenarios.length - 1) {
          _currentScenarioIndex++;
          _state = TrainingState.scenario;
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
    return question.correctAnswerId == answerId;
  }
}

