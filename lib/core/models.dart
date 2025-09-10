enum Tactic {
  urgency,
  authority,
  socialProof,
  footInTheDoor,
  emotion,
  normActivation,
  impersonation,
  socialEngineering,
}

class Rule {
  final String id;
  final String name;
  final Tactic tactic;
  final RegExp regex;
  final String explanation;
  final double weight;

  const Rule({
    required this.id,
    required this.name,
    required this.tactic,
    required this.regex,
    required this.explanation,
    required this.weight,
  });
}

class RuleHit {
  final Rule rule;
  RuleHit(this.rule);

  String get id => rule.id;
  String get label => rule.name;
  String get tactic => rule.tactic.toString().split('.').last;
  String get explanation => rule.explanation;
}

class DetectionResult {
  final double riskScore;
  final String riskLabel;
  final List<RuleHit> hits;
  final List<String> suggestions;

  DetectionResult({
    required this.riskScore,
    required this.riskLabel,
    required this.hits,
    required this.suggestions,
  });
}

class Scenario {
  // To be implemented in 0.2
}
