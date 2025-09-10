import 'dart:math';
import 'package:scamshield/content/schema.dart';

class SdatQuiz {
  final List<QuizItem> _scamItems;
  final List<QuizItem> _notScamItems;
  final List<QuizItem> _currentQuizItems = [];

  SdatQuiz({required List<Scenario> allScenarios})
    : _scamItems = _extractQuizItems(allScenarios, isScam: true),
      _notScamItems = _extractQuizItems(allScenarios, isScam: false) {
    _generateQuiz();
  }

  static List<QuizItem> _extractQuizItems(
    List<Scenario> scenarios, {
    required bool isScam,
  }) {
    final List<QuizItem> items = [];
    for (final scenario in scenarios) {
      // For simplicity, let's assume scenarios with tacticTags are 'scam' scenarios
      // and scenarios without tacticTags (or a specific tag) are 'not-scam'
      // This needs to be refined based on actual content design.
      // For now, we'll use the first quiz item from each scenario.
      if (scenario.tacticTags.isNotEmpty == isScam &&
          scenario.quiz.items.isNotEmpty) {
        items.add(scenario.quiz.items.first);
      }
    }
    return items;
  }

  void _generateQuiz() {
    _currentQuizItems.clear();
    final random = Random();

    // Select 5 scam items
    _scamItems.shuffle(random);
    _currentQuizItems.addAll(_scamItems.take(5));

    // Select 5 not-scam items
    _notScamItems.shuffle(random);
    _currentQuizItems.addAll(_notScamItems.take(5));

    _currentQuizItems.shuffle(random); // Randomize order of all 10 items
  }

  List<QuizItem> get quizItems => _currentQuizItems;

  // Scoring logic (simplified)
  int scoreQuiz(Map<String, String> userAnswers) {
    int score = 0;
    for (final item in _currentQuizItems) {
      if (userAnswers[item.id] == item.correctAnswerId) {
        score++;
      }
    }
    return score;
  }

  String getSummary(int score) {
    if (score == 10) {
      return "Excellent! You're a scam-spotting pro!";
    } else if (score >= 7) {
      return "Good job! You're getting better at spotting scams.";
    } else {
      return "Keep practicing! Scams can be tricky.";
    }
  }
}
