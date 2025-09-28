import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum UserLevel {
  rookie(0, 'Rookie', 0xFF4CAF50),
  detective(500, 'Detective', 0xFF2196F3),
  expert(1500, 'Expert', 0xFFFF9800),
  master(3000, 'Master', 0xFF9C27B0),
  legend(5000, 'Legend', 0xFFFFD700);

  const UserLevel(this.requiredXP, this.title, this.colorValue);
  final int requiredXP;
  final String title;
  final int colorValue;

  static UserLevel getLevelForXP(int xp) {
    for (int i = UserLevel.values.length - 1; i >= 0; i--) {
      if (xp >= UserLevel.values[i].requiredXP) {
        return UserLevel.values[i];
      }
    }
    return UserLevel.rookie;
  }

  int get progressToNext {
    final nextIndex = index + 1;
    if (nextIndex >= UserLevel.values.length) return 0;
    return UserLevel.values[nextIndex].requiredXP;
  }
}

class ScenarioProgress {
  final String scenarioId;
  final bool isCompleted;
  final bool isMastered; // Gold/Star badge
  final int bestScore;
  final int timesPlayed;
  final DateTime? lastPlayed;
  final List<String> choicesHistory;
  final int trustScore; // Trust calibration score
  final bool wasOverlySuspicious; // Rejected legitimate content
  final bool wasOverlyTrusting; // Trusted scam content

  ScenarioProgress({
    required this.scenarioId,
    this.isCompleted = false,
    this.isMastered = false,
    this.bestScore = 0,
    this.timesPlayed = 0,
    this.lastPlayed,
    this.choicesHistory = const [],
    this.trustScore = 0,
    this.wasOverlySuspicious = false,
    this.wasOverlyTrusting = false,
  });

  factory ScenarioProgress.fromJson(Map<String, dynamic> json) {
    return ScenarioProgress(
      scenarioId: json['scenarioId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isMastered: json['isMastered'] as bool? ?? false,
      bestScore: json['bestScore'] as int? ?? 0,
      timesPlayed: json['timesPlayed'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
      choicesHistory: List<String>.from(json['choicesHistory'] ?? []),
      trustScore: json['trustScore'] as int? ?? 0,
      wasOverlySuspicious: json['wasOverlySuspicious'] as bool? ?? false,
      wasOverlyTrusting: json['wasOverlyTrusting'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'isCompleted': isCompleted,
      'isMastered': isMastered,
      'bestScore': bestScore,
      'timesPlayed': timesPlayed,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'choicesHistory': choicesHistory,
      'trustScore': trustScore,
      'wasOverlySuspicious': wasOverlySuspicious,
      'wasOverlyTrusting': wasOverlyTrusting,
    };
  }

  ScenarioProgress copyWith({
    bool? isCompleted,
    bool? isMastered,
    int? bestScore,
    int? timesPlayed,
    DateTime? lastPlayed,
    List<String>? choicesHistory,
    int? trustScore,
    bool? wasOverlySuspicious,
    bool? wasOverlyTrusting,
  }) {
    return ScenarioProgress(
      scenarioId: scenarioId,
      isCompleted: isCompleted ?? this.isCompleted,
      isMastered: isMastered ?? this.isMastered,
      bestScore: bestScore ?? this.bestScore,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      choicesHistory: choicesHistory ?? this.choicesHistory,
      trustScore: trustScore ?? this.trustScore,
      wasOverlySuspicious: wasOverlySuspicious ?? this.wasOverlySuspicious,
      wasOverlyTrusting: wasOverlyTrusting ?? this.wasOverlyTrusting,
    );
  }
}

class UserProgress {
  final int totalXP;
  final UserLevel currentLevel;
  final int currentStreak;
  final DateTime? lastPlayDate;
  final Map<String, ScenarioProgress> scenarioProgress;
  final bool hasSeenTutorial;
  final Map<String, bool> dailyChallenges;
  final int bestStreak;
  final int overallTrustScore; // Overall trust calibration
  final int scamsIdentified; // Count of correctly identified scams
  final int legitimateRejected; // Count of incorrectly rejected legitimate content

  UserProgress({
    this.totalXP = 0,
    this.currentLevel = UserLevel.rookie,
    this.currentStreak = 0,
    this.lastPlayDate,
    this.scenarioProgress = const {},
    this.hasSeenTutorial = false,
    this.dailyChallenges = const {},
    this.bestStreak = 0,
    this.overallTrustScore = 0,
    this.scamsIdentified = 0,
    this.legitimateRejected = 0,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final scenarioProgressMap = <String, ScenarioProgress>{};
    final scenarioData = json['scenarioProgress'] as Map<String, dynamic>? ?? {};

    for (final entry in scenarioData.entries) {
      scenarioProgressMap[entry.key] = ScenarioProgress.fromJson(
        entry.value as Map<String, dynamic>
      );
    }

    final dailyChallengesData = json['dailyChallenges'] as Map<String, dynamic>? ?? {};
    final dailyChallengesMap = <String, bool>{};
    for (final entry in dailyChallengesData.entries) {
      dailyChallengesMap[entry.key] = entry.value as bool? ?? false;
    }

    return UserProgress(
      totalXP: json['totalXP'] as int? ?? 0,
      currentLevel: UserLevel.getLevelForXP(json['totalXP'] as int? ?? 0),
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastPlayDate: json['lastPlayDate'] != null
          ? DateTime.parse(json['lastPlayDate'] as String)
          : null,
      scenarioProgress: scenarioProgressMap,
      hasSeenTutorial: json['hasSeenTutorial'] as bool? ?? false,
      dailyChallenges: dailyChallengesMap,
      bestStreak: json['bestStreak'] as int? ?? 0,
      overallTrustScore: json['overallTrustScore'] as int? ?? 0,
      scamsIdentified: json['scamsIdentified'] as int? ?? 0,
      legitimateRejected: json['legitimateRejected'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final scenarioProgressJson = <String, dynamic>{};
    for (final entry in scenarioProgress.entries) {
      scenarioProgressJson[entry.key] = entry.value.toJson();
    }

    return {
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'lastPlayDate': lastPlayDate?.toIso8601String(),
      'scenarioProgress': scenarioProgressJson,
      'hasSeenTutorial': hasSeenTutorial,
      'dailyChallenges': dailyChallenges,
      'bestStreak': bestStreak,
      'overallTrustScore': overallTrustScore,
      'scamsIdentified': scamsIdentified,
      'legitimateRejected': legitimateRejected,
    };
  }

  // Calculate completion stats
  int get completedScenarios => scenarioProgress.values
      .where((progress) => progress.isCompleted)
      .length;

  int get masteredScenarios => scenarioProgress.values
      .where((progress) => progress.isMastered)
      .length;

  double get completionPercentage => scenarioProgress.isEmpty
      ? 0.0
      : completedScenarios / scenarioProgress.length;

  // Streak calculations
  UserProgress updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastPlayDate == null) {
      // First time playing
      return copyWith(
        currentStreak: 1,
        lastPlayDate: today,
        bestStreak: 1,
      );
    }

    final lastPlay = DateTime(lastPlayDate!.year, lastPlayDate!.month, lastPlayDate!.day);
    final daysDifference = today.difference(lastPlay).inDays;

    if (daysDifference == 1) {
      // Played yesterday, continue streak
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        lastPlayDate: today,
        bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
      );
    } else if (daysDifference == 0) {
      // Played today already, no change
      return this;
    } else {
      // Missed a day, reset streak
      return copyWith(
        currentStreak: 1,
        lastPlayDate: today,
      );
    }
  }

  bool get hasPlayedToday {
    if (lastPlayDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlay = DateTime(lastPlayDate!.year, lastPlayDate!.month, lastPlayDate!.day);
    return today == lastPlay;
  }

  int get streakMilestone {
    if (currentStreak >= 30) return 30;
    if (currentStreak >= 7) return 7;
    if (currentStreak >= 3) return 3;
    return 0;
  }

  // XP and level progression
  int get xpToNextLevel {
    final nextLevel = UserLevel.values
        .where((level) => level.requiredXP > totalXP)
        .firstOrNull;
    return nextLevel?.requiredXP ?? currentLevel.requiredXP;
  }

  double get levelProgress {
    final nextLevelXP = xpToNextLevel;
    if (nextLevelXP == currentLevel.requiredXP) return 1.0;

    final progressInLevel = totalXP - currentLevel.requiredXP;
    final levelRange = nextLevelXP - currentLevel.requiredXP;

    return levelRange > 0 ? progressInLevel / levelRange : 1.0;
  }

  UserProgress copyWith({
    int? totalXP,
    int? currentStreak,
    DateTime? lastPlayDate,
    Map<String, ScenarioProgress>? scenarioProgress,
    bool? hasSeenTutorial,
    Map<String, bool>? dailyChallenges,
    int? bestStreak,
  }) {
    final newXP = totalXP ?? this.totalXP;
    return UserProgress(
      totalXP: newXP,
      currentLevel: UserLevel.getLevelForXP(newXP),
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      scenarioProgress: scenarioProgress ?? this.scenarioProgress,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  // Persistence
  static const String _storageKey = 'user_progress';

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(toJson()));
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  static Future<UserProgress> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressString = prefs.getString(_storageKey);

      if (progressString != null) {
        final progressJson = json.decode(progressString) as Map<String, dynamic>;
        final progress = UserProgress.fromJson(progressJson);

        // Update streak based on last play date
        return progress.updateStreak();
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }

    return UserProgress(); // Return default progress
  }
}