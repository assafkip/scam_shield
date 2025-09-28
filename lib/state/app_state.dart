import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scenario.dart';
import '../models/badge.dart';

class AppState extends ChangeNotifier {
  double trustScore = 50;
  int currentStreak = 0;
  int bestStreak = 0;
  int totalScenariosPlayed = 0;
  int correctIdentifications = 0;
  int falseAlarms = 0;
  int scamsCaught = 0;
  int perfectScores = 0;
  DateTime? lastPlayedDate;
  bool dailyChallengePlayedToday = false;
  
  List<Scenario> scenarios = [];
  List<Map<String, dynamic>> dynamicScenarios = [];
  int currentScenarioIndex = 0;
  List<ScenarioBadge> earnedBadges = [];
  
  Scenario get current => scenarios[currentScenarioIndex];
  
  Future<void> loadScenarios() async {
    try {
      print('🔄 Starting to load scenarios');
      String jsonString;

      // Standardized asset loading - try standard path first, then web path
      try {
        jsonString = await rootBundle.loadString('assets/scenarios.json');
        print('✅ Loaded from standard path: assets/scenarios.json');
      } catch (e) {
        try {
          jsonString = await rootBundle.loadString('assets/assets/scenarios.json');
          print('✅ Loaded from web fallback path: assets/assets/scenarios.json');
        } catch (e2) {
          print('❌ Failed to load from both paths');
          print('❌ Standard path error: $e');
          print('❌ Web path error: $e2');
          rethrow;
        }
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      scenarios = jsonList.map((json) => Scenario.fromJson(json)).toList();

      print('✅ Successfully loaded ${scenarios.length} scenarios');
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ ERROR loading scenarios: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  void nextScenario() {
    currentScenarioIndex = (currentScenarioIndex + 1) % scenarios.length;
    notifyListeners();
  }
  
  int score(int slider) {
    final scenario = current;
    int delta = 0;
    
    if (scenario.isScam) {
      if (slider > 70) {
        delta = 20;
        scamsCaught++;
        correctIdentifications++;
        if (slider >= 90) {
          perfectScores++;
        }
      } else if (slider < 30) {
        delta = -50;
      }
    } else {
      if (slider < 40) {
        delta = 15;
        correctIdentifications++;
        if (slider <= 10) {
          perfectScores++;
        }
      } else if (slider > 80) {
        delta = -30;
        falseAlarms++;
      }
    }
    
    trustScore = (trustScore + delta).clamp(0, 100);
    totalScenariosPlayed++;
    
    // Update streaks
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (lastPlayedDate != null) {
      final lastDate = DateTime(lastPlayedDate!.year, lastPlayedDate!.month, lastPlayedDate!.day);
      final daysDiff = todayDate.difference(lastDate).inDays;
      
      if (daysDiff == 0) {
        // Already played today, no streak change
      } else if (daysDiff == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }
    
    lastPlayedDate = today;
    bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;
    
    notifyListeners();
    return delta;
  }

  // Badge management methods
  ScenarioBadge? awardBadge(int userTrustLevel, bool wasCorrect) {
    final scenarioId = current.id;

    // Check if badge already exists for this scenario
    final existingBadge = earnedBadges
        .where((badge) => badge.scenarioId == scenarioId)
        .firstOrNull;

    final badgeType = BadgeTypeExtension.calculateBadgeType(userTrustLevel, current.isScam);

    // Award new badge or upgrade existing one
    if (existingBadge == null || badgeType.index > existingBadge.type.index) {
      // Remove existing badge if upgrading
      if (existingBadge != null) {
        earnedBadges.removeWhere((badge) => badge.scenarioId == scenarioId);
      }

      final newBadge = ScenarioBadge(
        scenarioId: scenarioId,
        type: badgeType,
        earnedAt: DateTime.now(),
      );

      earnedBadges.add(newBadge);
      _saveBadgesToStorage();
      notifyListeners();

      return newBadge;
    }

    return null; // No new badge awarded
  }

  Future<void> _saveBadgesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final badgesJson = earnedBadges.map((badge) => badge.toJson()).toList();
      await prefs.setString('earned_badges', json.encode(badgesJson));
    } catch (e) {
      print('Error saving badges to storage: $e');
    }
  }

  Future<void> loadBadgesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final badgesString = prefs.getString('earned_badges');

      if (badgesString != null) {
        final badgesJson = json.decode(badgesString) as List;
        earnedBadges = badgesJson
            .map((badgeJson) => ScenarioBadge.fromJson(badgeJson as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading badges from storage: $e');
    }
  }

  ScenarioBadge? getBadgeForScenario(String scenarioId) {
    return earnedBadges
        .where((badge) => badge.scenarioId == scenarioId)
        .firstOrNull;
  }

  List<String> get allScenarioIds {
    return scenarios.map((scenario) => scenario.id).toList();
  }

  int get completedScenariosCount {
    return earnedBadges.length;
  }

  int get masteredScenariosCount {
    return earnedBadges
        .where((badge) => badge.type == BadgeType.gold || badge.type == BadgeType.star)
        .length;
  }

  double get completionPercentage {
    if (scenarios.isEmpty) return 0.0;
    return earnedBadges.length / scenarios.length;
  }

  List<ScenarioBadge> getBadgesByType(BadgeType type) {
    return earnedBadges.where((badge) => badge.type == type).toList();
  }

  Future<void> loadDynamicScenarios() async {
    try {
      print('🔄 Loading enhanced dynamic scenarios with trust calibration');
      String jsonString;

      // Try enhanced scenarios first (with trust calibration)
      try {
        jsonString = await rootBundle.loadString('assets/enhanced_dynamic_scenarios.json');
        print('✅ Loaded enhanced dynamic scenarios with trust calibration');
      } catch (e) {
        try {
          jsonString = await rootBundle.loadString('assets/assets/enhanced_dynamic_scenarios.json');
          print('✅ Loaded enhanced dynamic scenarios from web fallback path');
        } catch (e2) {
          // Fallback to original dynamic scenarios
          try {
            jsonString = await rootBundle.loadString('assets/dynamic_scenarios.json');
            print('⚠️ Loaded fallback dynamic scenarios (no trust calibration)');
          } catch (e3) {
            try {
              jsonString = await rootBundle.loadString('assets/assets/dynamic_scenarios.json');
              print('⚠️ Loaded fallback dynamic scenarios from web path');
            } catch (e4) {
              print('❌ Failed to load any dynamic scenarios');
              return;
            }
          }
        }
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      dynamicScenarios = jsonList.cast<Map<String, dynamic>>();

      print('✅ Successfully loaded ${dynamicScenarios.length} dynamic scenarios');
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ ERROR loading dynamic scenarios: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  // Initialize app - load scenarios and badges
  Future<void> initializeApp() async {
    try {
      await loadScenarios();
      await loadDynamicScenarios();
      await loadBadgesFromStorage();
      print('✅ App initialization complete');
    } catch (e) {
      print('❌ Error during app initialization: $e');
    }
  }
}