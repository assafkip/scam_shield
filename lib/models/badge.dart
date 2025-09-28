enum BadgeType {
  bronze,
  silver,
  gold,
  star,
}

class ScenarioBadge {
  final String scenarioId;
  final BadgeType type;
  final DateTime earnedAt;

  ScenarioBadge({
    required this.scenarioId,
    required this.type,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'type': type.index,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  factory ScenarioBadge.fromJson(Map<String, dynamic> json) {
    return ScenarioBadge(
      scenarioId: json['scenarioId'] as String,
      type: BadgeType.values[json['type'] as int],
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }

  String get emoji {
    switch (type) {
      case BadgeType.bronze:
        return '🥉';
      case BadgeType.silver:
        return '🥈';
      case BadgeType.gold:
        return '🥇';
      case BadgeType.star:
        return '⭐';
    }
  }

  String get title {
    switch (type) {
      case BadgeType.bronze:
        return 'Bronze';
      case BadgeType.silver:
        return 'Silver';
      case BadgeType.gold:
        return 'Gold';
      case BadgeType.star:
        return 'Star';
    }
  }

  String get description {
    switch (type) {
      case BadgeType.bronze:
        return 'Completed scenario';
      case BadgeType.silver:
        return 'Good performance';
      case BadgeType.gold:
        return 'Excellent performance';
      case BadgeType.star:
        return 'Perfect performance';
    }
  }

}

extension BadgeTypeExtension on BadgeType {
  static BadgeType calculateBadgeType(int userTrustLevel, bool isScam) {
    final optimalLevel = isScam ? 15 : 85;
    final difference = (userTrustLevel - optimalLevel).abs();

    if (difference <= 5) {
      return BadgeType.star; // Perfect
    } else if (difference <= 15) {
      return BadgeType.gold; // Excellent
    } else if (difference <= 30) {
      return BadgeType.silver; // Good
    } else {
      return BadgeType.bronze; // Completed
    }
  }
}