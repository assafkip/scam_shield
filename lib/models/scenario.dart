class Scenario {
  final String id;
  final String title;
  final String context;
  final List<String> tacticTags;
  final List<Indicator>? indicators;
  final List<ScenarioStep> steps;
  final String debrief;
  final Quiz quiz;
  final Provenance? provenance;

  Scenario({
    required this.id,
    required this.title,
    required this.context,
    required this.tacticTags,
    this.indicators,
    required this.steps,
    required this.debrief,
    required this.quiz,
    this.provenance,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'],
      title: json['title'],
      context: json['context'],
      tacticTags: List<String>.from(json['tacticTags']),
      indicators: json['indicators'] != null
          ? (json['indicators'] as List).map((i) => Indicator.fromJson(i)).toList()
          : null,
      steps: (json['steps'] as List).map((s) => ScenarioStep.fromJson(s)).toList(),
      debrief: json['debrief'],
      quiz: Quiz.fromJson(json['quiz']),
      provenance: json['provenance'] != null ? Provenance.fromJson(json['provenance']) : null,
    );
  }
}

class Indicator {
  final String type;
  final String text;

  Indicator({required this.type, required this.text});

  factory Indicator.fromJson(Map<String, dynamic> json) {
    return Indicator(type: json['type'], text: json['text']);
  }
}

class ScenarioStep {
  final String text;
  final List<Choice> choices;
  final String feedback;

  ScenarioStep({
    required this.text,
    required this.choices,
    required this.feedback,
  });

  factory ScenarioStep.fromJson(Map<String, dynamic> json) {
    return ScenarioStep(
      text: json['text'],
      choices: (json['choices'] as List).map((c) => Choice.fromJson(c)).toList(),
      feedback: json['feedback'],
    );
  }
}

class Choice {
  final String label;
  final bool safe;
  final String next;

  Choice({required this.label, required this.safe, required this.next});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      label: json['label'],
      safe: json['safe'],
      next: json['next'],
    );
  }
}

class Quiz {
  final List<QuizItem> items;

  Quiz({required this.items});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      items: (json['items'] as List).map((i) => QuizItem.fromJson(i)).toList(),
    );
  }
}

class QuizItem {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizItem({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }
}

class Provenance {
  final String source;
  final String url;

  Provenance({required this.source, required this.url});

  factory Provenance.fromJson(Map<String, dynamic> json) {
    return Provenance(source: json['source'], url: json['url']);
  }
}

enum BadgeType { bronze, silver, gold, star }

enum CompanionState { neutral, happy, sad, concerned }