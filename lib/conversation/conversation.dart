/// Unified conversation models for PRD-01
/// Consolidates legacy interactive_chat, research_scenario, and dynamic_chat engines

class UnifiedConversation {
  final String id;
  final String title;
  final String context; // dating|support|marketplace|job|crypto|...
  final String? skin; // whatsapp|gmail|sms|tinder|null for default
  final List<ConversationStep> steps;
  final List<QuizQuestion> quiz;
  final ConsequenceRules consequenceRules;

  const UnifiedConversation({
    required this.id,
    required this.title,
    required this.context,
    this.skin,
    required this.steps,
    this.quiz = const [],
    required this.consequenceRules,
  });

  factory UnifiedConversation.fromJson(Map<String, dynamic> json) {
    return UnifiedConversation(
      id: json['id'] as String,
      title: json['title'] as String,
      context: json['context'] as String,
      skin: json['skin'] as String?,
      steps: (json['steps'] as List)
          .map((step) => ConversationStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      consequenceRules: ConsequenceRules.fromJson(
          json['consequenceRules'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'context': context,
      if (skin != null) 'skin': skin,
      'steps': steps.map((step) => step.toJson()).toList(),
      'quiz': quiz.map((q) => q.toJson()).toList(),
      'consequenceRules': consequenceRules.toJson(),
    };
  }

  /// Get step by ID, returns null if not found
  ConversationStep? getStepById(String stepId) {
    try {
      return steps.firstWhere((step) => step.id == stepId);
    } catch (e) {
      return null;
    }
  }

  /// Validate conversation meets quality requirements
  ConversationQuality validateQuality() {
    final depth = steps.length;
    final branchingPoints = steps
        .where((step) => step.choices.length >= 2)
        .length;

    final allTactics = steps
        .expand((step) => step.choices)
        .expand((choice) => choice.tactics)
        .toSet();

    return ConversationQuality(
      depth: depth,
      branchingPoints: branchingPoints,
      tacticsCovered: allTactics.toList(),
      meetsDepthRequirement: depth >= 8,
      meetsBranchingRequirement: branchingPoints >= 2,
    );
  }
}

class ConversationStep {
  final String id;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;

  const ConversationStep({
    required this.id,
    required this.messages,
    this.choices = const [],
  });

  factory ConversationStep.fromJson(Map<String, dynamic> json) {
    return ConversationStep(
      id: json['id'] as String,
      messages: (json['messages'] as List)
          .map((msg) => ConversationMessage.fromJson(msg as Map<String, dynamic>))
          .toList(),
      choices: (json['choices'] as List? ?? [])
          .map((choice) => ConversationChoice.fromJson(choice as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'choices': choices.map((choice) => choice.toJson()).toList(),
    };
  }

  bool get isEndStep => choices.isEmpty;
}

class ConversationMessage {
  final String speaker;
  final String text;
  final DateTime? timestamp;

  const ConversationMessage({
    required this.speaker,
    required this.text,
    this.timestamp,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'text': text,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}

class ConversationChoice {
  final String id;
  final String label;
  final bool safe;
  final String next; // next step ID or 'debrief'
  final List<String> tactics;
  final double pressureDelta; // -5.0 to +15.0
  final double trustHint; // 0.0 to 1.0

  const ConversationChoice({
    required this.id,
    required this.label,
    required this.safe,
    required this.next,
    this.tactics = const [],
    this.pressureDelta = 0.0,
    this.trustHint = 0.5,
  });

  factory ConversationChoice.fromJson(Map<String, dynamic> json) {
    return ConversationChoice(
      id: json['id'] as String,
      label: json['label'] as String,
      safe: json['safe'] as bool,
      next: json['next'] as String,
      tactics: (json['tactics'] as List? ?? []).cast<String>(),
      pressureDelta: (json['pressureDelta'] as num?)?.toDouble() ?? 0.0,
      trustHint: (json['trustHint'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'safe': safe,
      'next': next,
      'tactics': tactics,
      'pressureDelta': pressureDelta,
      'trustHint': trustHint,
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['q'] as String,
      options: (json['options'] as List).cast<String>(),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

class ConsequenceRules {
  final ConsequenceOutcome? onScam;
  final ConsequenceOutcome? onParanoid;
  final ConsequenceOutcome? onCalibrated;

  const ConsequenceRules({
    this.onScam,
    this.onParanoid,
    this.onCalibrated,
  });

  factory ConsequenceRules.fromJson(Map<String, dynamic> json) {
    return ConsequenceRules(
      onScam: json['onScam'] != null
          ? ConsequenceOutcome.fromJson(json['onScam'] as Map<String, dynamic>)
          : null,
      onParanoid: json['onParanoid'] != null
          ? ConsequenceOutcome.fromJson(json['onParanoid'] as Map<String, dynamic>)
          : null,
      onCalibrated: json['onCalibrated'] != null
          ? ConsequenceOutcome.fromJson(json['onCalibrated'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (onScam != null) 'onScam': onScam!.toJson(),
      if (onParanoid != null) 'onParanoid': onParanoid!.toJson(),
      if (onCalibrated != null) 'onCalibrated': onCalibrated!.toJson(),
    };
  }
}

class ConsequenceOutcome {
  final int? lossUSD;
  final String? missedOpportunity;
  final String? unlock;

  const ConsequenceOutcome({
    this.lossUSD,
    this.missedOpportunity,
    this.unlock,
  });

  factory ConsequenceOutcome.fromJson(Map<String, dynamic> json) {
    return ConsequenceOutcome(
      lossUSD: json['lossUSD'] as int?,
      missedOpportunity: json['missedOpportunity'] as String?,
      unlock: json['unlock'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lossUSD != null) 'lossUSD': lossUSD,
      if (missedOpportunity != null) 'missedOpportunity': missedOpportunity,
      if (unlock != null) 'unlock': unlock,
    };
  }
}

/// Quality validation result for golden tests
class ConversationQuality {
  final int depth;
  final int branchingPoints;
  final List<String> tacticsCovered;
  final bool meetsDepthRequirement;
  final bool meetsBranchingRequirement;

  const ConversationQuality({
    required this.depth,
    required this.branchingPoints,
    required this.tacticsCovered,
    required this.meetsDepthRequirement,
    required this.meetsBranchingRequirement,
  });

  bool get passesGoldenTests => meetsDepthRequirement && meetsBranchingRequirement;

  static const requiredTactics = [
    'authority', 'urgency', 'social_proof',
    'emotion', 'foot_in_door', 'norm_activation'
  ];

  bool get hasRequiredTactics {
    return requiredTactics.any((tactic) => tacticsCovered.contains(tactic));
  }
}

/// Conversation state during playback
class ConversationState {
  final String conversationId;
  final String currentStepId;
  final List<String> visitedSteps;
  final Map<String, ConversationChoice> userChoices;
  final double currentPressure;
  final double currentTrust;
  final bool isCompleted;
  final List<PressureTrace> pressureTrace;
  final List<double> trustHistory;

  const ConversationState({
    required this.conversationId,
    required this.currentStepId,
    this.visitedSteps = const [],
    this.userChoices = const {},
    this.currentPressure = 0.0,
    this.currentTrust = 0.5,
    this.isCompleted = false,
    this.pressureTrace = const [],
    this.trustHistory = const [],
  });

  ConversationState copyWith({
    String? conversationId,
    String? currentStepId,
    List<String>? visitedSteps,
    Map<String, ConversationChoice>? userChoices,
    double? currentPressure,
    double? currentTrust,
    bool? isCompleted,
    List<PressureTrace>? pressureTrace,
    List<double>? trustHistory,
  }) {
    return ConversationState(
      conversationId: conversationId ?? this.conversationId,
      currentStepId: currentStepId ?? this.currentStepId,
      visitedSteps: visitedSteps ?? this.visitedSteps,
      userChoices: userChoices ?? this.userChoices,
      currentPressure: currentPressure ?? this.currentPressure,
      currentTrust: currentTrust ?? this.currentTrust,
      isCompleted: isCompleted ?? this.isCompleted,
      pressureTrace: pressureTrace ?? this.pressureTrace,
      trustHistory: trustHistory ?? this.trustHistory,
    );
  }

  /// Apply a choice to the state, updating trust and pressure
  ConversationState applyChoice(ConversationChoice choice, String stepId) {
    final newTrustHistory = [...trustHistory, choice.trustHint];
    final newTrustScore = newTrustHistory.isEmpty ? 0.5
        : newTrustHistory.reduce((a, b) => a + b) / newTrustHistory.length;

    final newPressure = (currentPressure + choice.pressureDelta).clamp(0.0, 100.0);

    final newTrace = [...pressureTrace, PressureTrace(
      stepId: stepId,
      choiceId: choice.id,
      pressureDelta: choice.pressureDelta,
      newPressureLevel: newPressure,
      timestamp: DateTime.now(),
    )];

    return copyWith(
      visitedSteps: [...visitedSteps, currentStepId],
      userChoices: {...userChoices, currentStepId: choice},
      currentPressure: newPressure,
      currentTrust: newTrustScore,
      trustHistory: newTrustHistory,
      pressureTrace: newTrace,
    );
  }

  /// Get trust score as percentage for display
  double get trustScorePercentage => (currentTrust * 100).clamp(0.0, 100.0);

  /// Get trust analysis for debrief
  String get trustAnalysis {
    if (currentTrust >= 0.8) {
      return 'You trusted too easily (${trustScorePercentage.toStringAsFixed(0)}%).';
    } else if (currentTrust <= 0.3) {
      return 'You were very cautious (${trustScorePercentage.toStringAsFixed(0)}% trust).';
    } else {
      return 'You showed balanced trust (${trustScorePercentage.toStringAsFixed(0)}%).';
    }
  }

  /// Get pressure analysis for debrief
  String get pressureAnalysis {
    if (pressureTrace.isEmpty) return 'No pressure changes recorded.';

    final increases = pressureTrace.where((t) => t.pressureDelta > 0).length;
    final decreases = pressureTrace.where((t) => t.pressureDelta < 0).length;

    if (increases > decreases) {
      return 'Scammer escalated pressure $increases times; you resisted $decreases times.';
    } else if (decreases > increases) {
      return 'You successfully resisted pressure $decreases times vs $increases escalations.';
    } else {
      return 'Pressure remained relatively stable throughout the conversation.';
    }
  }
}

/// Records pressure changes for analysis
class PressureTrace {
  final String stepId;
  final String choiceId;
  final double pressureDelta;
  final double newPressureLevel;
  final DateTime timestamp;

  const PressureTrace({
    required this.stepId,
    required this.choiceId,
    required this.pressureDelta,
    required this.newPressureLevel,
    required this.timestamp,
  });
}