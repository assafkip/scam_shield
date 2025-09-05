import 'dart:math';

import 'models.dart';

class Detector {
  static final _rules = <Rule>[
    Rule(
        id: 'URGENCY_NOW',
        name: 'Urgency push',
        tactic: Tactic.urgency,
        regex: RegExp(r'(now|today|immediately|urgent)', caseSensitive: false),
        explanation: 'Creates a false sense of pressure.',
        weight: 0.2),
    Rule(
        id: 'AUTHORITY_BANK',
        name: 'Authority name-drop',
        tactic: Tactic.authority,
        regex: RegExp(r'(bank|fraud alert|security notice)', caseSensitive: false),
        explanation: 'Impersonates a figure of authority.',
        weight: 0.3),
    Rule(
        id: 'SOCIAL_PROOF_WIN',
        name: 'Social Proof',
        tactic: Tactic.socialProof,
        regex: RegExp(r'(you have won|winner|prize)', caseSensitive: false),
        explanation: 'Claims others are participating or winning.',
        weight: 0.25),
    Rule(
        id: 'FITD_CLICK_LINK',
        name: 'Suspicious link',
        tactic: Tactic.footInTheDoor,
        regex: RegExp(r'https?:\/\/[^\s]+', caseSensitive: false),
        explanation: 'Asks for a small action (clicking a link).',
        weight: 0.1),
    Rule(
        id: 'EMOTION_FEAR',
        name: 'Emotion Fear',
        tactic: Tactic.emotion,
        regex: RegExp(r'(account suspended|locked|compromised)', caseSensitive: false),
        explanation: 'Manipulates fear or anxiety.',
        weight: 0.3),
    Rule(
        id: 'NORM_ACT_PAY',
        name: 'Norm Activation',
        tactic: Tactic.normActivation,
        regex: RegExp(r'(payment due|invoice|overdue)', caseSensitive: false),
        explanation: 'Triggers a sense of social obligation.',
        weight: 0.2),
  ];

  static final _comboBonuses = <Map<String, dynamic>>[
    {
      'ids': ['AUTHORITY_BANK', 'EMOTION_FEAR'],
      'bonus': 0.15
    }
  ];

  static final _riskThresholds = {
    'Strong Warning': 0.8,
    'Caution': 0.5,
    'Info': 0.0,
  };

  static DetectionResult analyze(String text) {
    if (text.trim().isEmpty) {
      return DetectionResult(
          riskScore: 0.0, riskLabel: 'Info', hits: [], suggestions: ["Paste a message to analyze."]);
    }

    final hits = <RuleHit>{};
    for (final rule in _rules) {
      if (rule.regex.hasMatch(text)) {
        hits.add(RuleHit(rule));
      }
    }

    var score = hits.fold<double>(0.0, (prev, hit) => prev + hit.rule.weight);

    for (final combo in _comboBonuses) {
      final ids = combo['ids'] as List<String>;
      if (ids.every((id) => hits.any((hit) => hit.id == id))) {
        score += combo['bonus'] as double;
      }
    }

    final riskScore = min(score, 1.0);

    var riskLabel = 'Info';
    for (final entry in _riskThresholds.entries) {
      if (riskScore >= entry.value) {
        riskLabel = entry.key;
        break;
      }
    }

    final suggestions = <String>[];
    if (hits.any((h) => h.id == 'FITD_CLICK_LINK')) suggestions.add("Avoid shortened/unknown links.");

    return DetectionResult(
      riskScore: riskScore,
      riskLabel: riskLabel,
      hits: hits.toList(),
      suggestions: suggestions,
    );
  }
}