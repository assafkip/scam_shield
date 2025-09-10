// Helper functions for null-safe JSON parsing
String _str(Map<String, dynamic> j, String k, [String d = '']) =>
    (j[k] as String?) ?? d;
bool _bool(Map<String, dynamic> j, String k, [bool d = false]) =>
    (j[k] as bool?) ?? d;
List<T> _list<T>(Map<String, dynamic> j, String k) {
  final v = j[k];
  return v is List ? v.cast<T>() : <T>[];
}

enum Tactic {
  authority,
  urgency,
  socialProof,
  emotion,
  footInTheDoor,
  normActivation,
}

class Scenario {
  final String id;
  final String title;
  final String context;
  final List<Tactic> tacticTags;
  final List<ScenarioStep> steps;
  final ScenarioQuiz quiz;

  Scenario({
    required this.id,
    required this.title,
    required this.context,
    required this.tacticTags,
    required this.steps,
    required this.quiz,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    final stepsList = _list<dynamic>(json, 'steps');
    final steps = stepsList.map((step) => ScenarioStep.fromJson(step)).toList();
    _checkDuplicateIds(steps.map((s) => s.id), 'ScenarioStep');

    final quizData =
        json['quiz'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final quiz = ScenarioQuiz.fromJson(quizData);

    final tacticsList = _list<dynamic>(json, 'tacticTags');
    final tacticTags = tacticsList
        .map(
          (tag) => Tactic.values.firstWhere(
            (e) => e.toString().split('.').last == tag.toString(),
            orElse: () => Tactic.emotion,
          ),
        )
        .toList();

    return Scenario(
      id: _str(json, 'id'),
      title: _str(json, 'title'),
      context: _str(json, 'context'),
      tacticTags: tacticTags,
      steps: steps,
      quiz: quiz,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'context': context,
      'tacticTags': tacticTags
          .map((tag) => tag.toString().split('.').last)
          .toList(),
      'steps': steps.map((step) => step.toJson()).toList(),
      'quiz': quiz.toJson(),
    };
  }
}

enum StepType { message, choice, debrief, quiz }

class ScenarioStep {
  final String id;
  final StepType type;
  final String text;
  final List<StepChoice>? choices; // Only for type: choice
  final bool? isCorrect; // Only for type: debrief
  final String? explanation; // Only for type: debrief

  ScenarioStep({
    required this.id,
    required this.type,
    required this.text,
    this.choices,
    this.isCorrect,
    this.explanation,
  });

  factory ScenarioStep.fromJson(Map<String, dynamic> json) {
    final choicesList = _list<dynamic>(json, 'choices');
    final choices = choicesList.isNotEmpty
        ? choicesList.map((choice) => StepChoice.fromJson(choice)).toList()
        : null;
    if (choices != null) {
      _checkDuplicateIds(choices.map((c) => c.id), 'StepChoice');
    }

    final typeStr = _str(json, 'type');
    final type = StepType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => StepType.message,
    );

    return ScenarioStep(
      id: _str(json, 'id'),
      type: type,
      text: _str(json, 'text'),
      choices: choices,
      isCorrect: json['isCorrect'] as bool?,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'text': text,
      'choices': choices?.map((choice) => choice.toJson()).toList(),
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}

class StepChoice {
  final String id;
  final String text;
  final bool isSafe; // Indicates if this choice is the "safe" option

  StepChoice({required this.id, required this.text, required this.isSafe});

  factory StepChoice.fromJson(Map<String, dynamic> json) {
    return StepChoice(
      id: _str(json, 'id'),
      text: _str(json, 'text'),
      isSafe: _bool(json, 'isSafe'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'isSafe': isSafe};
  }
}

class ScenarioQuiz {
  final List<QuizItem> items;

  ScenarioQuiz({required this.items});

  factory ScenarioQuiz.fromJson(Map<String, dynamic> json) {
    final itemsList = _list<dynamic>(json, 'items');
    final items = itemsList.map((item) => QuizItem.fromJson(item)).toList();
    _checkDuplicateIds(items.map((i) => i.id), 'QuizItem');

    return ScenarioQuiz(items: items);
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }
}

class QuizItem {
  final String id;
  final String question;
  final List<QuizOption> options;
  final String correctAnswerId;

  QuizItem({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerId,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    final optionsList = _list<dynamic>(json, 'options');
    final options = optionsList
        .map((option) => QuizOption.fromJson(option))
        .toList();
    _checkDuplicateIds(options.map((o) => o.id), 'QuizOption');

    return QuizItem(
      id: _str(json, 'id'),
      question: _str(json, 'question'),
      options: options,
      correctAnswerId: _str(json, 'correctAnswerId'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'correctAnswerId': correctAnswerId,
    };
  }
}

class QuizOption {
  final String id;
  final String text;

  QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(id: _str(json, 'id'), text: _str(json, 'text'));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text};
  }
}

void _checkDuplicateIds(Iterable<String> ids, String type) {
  final uniqueIds = ids.toSet();
  if (uniqueIds.length != ids.length) {
    throw StateError('Duplicate IDs found in $type list.');
  }
}
