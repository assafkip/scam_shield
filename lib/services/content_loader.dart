import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:scamshield/models/scenario.dart';

class ContentLoader {
  static final List<Scenario> _scenarios = [];
  static bool _loaded = false;

  static Future<List<Scenario>> loadScenarios() async {
    if (_loaded) return _scenarios;

    // Load all scenario files
    final scenarioFiles = [
      'tech_support.json',
      'romance_platformhop.json',
      'sextortion.json',
      'crypto_investment.json',
      'marketplace_qr.json',
      'job_recruiter.json',
      'irs_imposter.json',
      'charity_scam.json',
      'rental_scam.json',
      'student_loan.json',
      'bank_imposter.json',
      'social_media.json',
    ];

    for (final file in scenarioFiles) {
      try {
        final jsonString = await rootBundle.loadString('assets/content/$file');
        final jsonData = json.decode(jsonString);
        _scenarios.add(Scenario.fromJson(jsonData));
      } catch (e) {
        // Skip files that don't exist or have errors
        print('Could not load $file: $e');
      }
    }

    _loaded = true;
    return _scenarios;
  }

  static List<Scenario> getYouthScenarios() {
    return _scenarios.where((s) => s.id.startsWith('y')).toList();
  }

  static List<Scenario> getCapsuleScenarios() {
    return _scenarios.where((s) => !s.id.startsWith('y')).toList();
  }

  static List<QuizItem> getQuickTestItems() {
    final allQuizItems = <QuizItem>[];
    for (final scenario in _scenarios) {
      allQuizItems.addAll(scenario.quiz.items);
    }
    
    // Shuffle and take 10 items (5 scam, 5 not-scam approximation)
    allQuizItems.shuffle();
    return allQuizItems.take(10).toList();
  }
}