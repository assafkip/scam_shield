import 'package:flutter_test/flutter_test.dart';
import '../lib/data/shieldup_scenarios.dart';
import '../lib/services/trust_calibration_engine.dart';
import 'dart:convert';
import 'dart:io';

/// Comprehensive validation tests for research-backed content
void main() {
  group('Research Content Validation', () {
    late List<ShieldUpScenario> allScenarios;

    setUpAll(() {
      allScenarios = ShieldUpScenario.getAllResearchScenarios();
    });

    test('All ShieldUp scenarios loaded successfully', () {
      expect(allScenarios.length, greaterThanOrEqualTo(8));
      print('✅ Loaded ${allScenarios.length} research scenarios');
    });

    test('Close to 50/50 scam to legitimate ratio', () {
      final scams = allScenarios.where((s) => s.isScam).toList();
      final legitimate = allScenarios.where((s) => !s.isScam).toList();

      // Expect 4 scams and 5 legitimate (44:56 ratio - close to 50:50)
      expect(scams.length, equals(4),
          reason: 'Should have 4 scam scenarios');
      expect(legitimate.length, equals(5),
          reason: 'Should have 5 legitimate scenarios');

      final ratio = scams.length / allScenarios.length;
      expect(ratio, closeTo(0.44, 0.1),
          reason: 'Scam ratio should be approximately 44%');

      print('✅ Close to 50/50 ratio: ${scams.length} scams, ${legitimate.length} legitimate (44:56)');
    });

    test('Every scenario has required research content', () {
      for (var scenario in allScenarios) {
        // Must have conversation
        expect(scenario.conversation.length, greaterThan(1),
            reason: 'Scenario ${scenario.id} must have multiple messages');

        // Must have victim testimony
        expect(scenario.victimTestimony, isNotEmpty,
            reason: 'Scenario ${scenario.id} must have victim testimony');

        // Must have research source
        expect(scenario.researchSource, isNotEmpty,
            reason: 'Scenario ${scenario.id} must cite research source');

        // Must have manipulation tactics if it's a scam
        if (scenario.isScam) {
          expect(scenario.manipulationTactics, isNotEmpty,
              reason: 'Scam ${scenario.id} must have manipulation tactics');
          expect(scenario.redFlags, isNotEmpty,
              reason: 'Scam ${scenario.id} must have red flags');
        }

        // Must have legitimate flags if it's not a scam
        if (!scenario.isScam) {
          expect(scenario.legitimateFlags, isNotEmpty,
              reason: 'Legitimate ${scenario.id} must have legitimate flags');
        }

        // Must have trust scoring table
        expect(scenario.trustScoring, isNotEmpty,
            reason: 'Scenario ${scenario.id} must have trust scoring');
        expect(scenario.trustScoring.keys, contains('very_suspicious'));
        expect(scenario.trustScoring.keys, contains('trusting'));
      }

      print('✅ All scenarios have required research content');
    });

    test('Optimal trust levels are properly calibrated', () {
      final scams = allScenarios.where((s) => s.isScam);
      final legitimate = allScenarios.where((s) => !s.isScam);

      // Scams should have low optimal trust levels
      for (var scam in scams) {
        expect(scam.optimalTrustLevel, lessThan(40),
            reason: 'Scam ${scam.id} should have low optimal trust (< 40)');
      }

      // Legitimate should have higher optimal trust levels
      for (var legit in legitimate) {
        expect(legit.optimalTrustLevel, greaterThan(50),
            reason: 'Legitimate ${legit.id} should have higher trust (> 50)');
      }

      print('✅ Trust levels properly calibrated');
    });

    test('Trust calibration engine works correctly', () {
      final scenario = allScenarios.first;

      // Test perfect calibration
      final perfectResult = TrustCalibrationEngine.evaluateResponse(
        userTrustLevel: scenario.optimalTrustLevel,
        scenario: scenario,
        timeToDecision: 20,
      );
      expect(perfectResult.points, greaterThan(75));
      expect(perfectResult.accuracy, equals('excellent'));

      // Test overly trusting of scam
      if (scenario.isScam) {
        final trustingResult = TrustCalibrationEngine.evaluateResponse(
          userTrustLevel: 90,
          scenario: scenario,
          timeToDecision: 20,
        );
        expect(trustingResult.points, lessThan(0));
        expect(trustingResult.accuracy, equals('overly_trusting'));
      }

      print('✅ Trust calibration engine functioning correctly');
    });

    test('Platform diversity is adequate', () {
      final platforms = allScenarios.map((s) => s.platform.toLowerCase()).toSet();

      expect(platforms, contains('whatsapp'));
      expect(platforms, contains('email'));
      expect(platforms, contains('sms'));
      expect(platforms.length, greaterThanOrEqualTo(4),
          reason: 'Must cover at least 4 different platforms');

      print('✅ Platform diversity: ${platforms.join(', ')}');
    });

    test('Manipulation tactics comprehensively covered', () {
      final allTactics = <String>{};

      for (var scenario in allScenarios.where((s) => s.isScam)) {
        allTactics.addAll(scenario.manipulationTactics);
      }

      // Must cover key manipulation categories
      final requiredTactics = [
        'emotional manipulation',
        'authority',
        'urgency',
        'fear',
        'social proof',
      ];

      for (var tactic in requiredTactics) {
        final hasTactic = allTactics.any((t) => t.toLowerCase().contains(tactic));
        expect(hasTactic, isTrue,
            reason: 'Must cover $tactic manipulation tactic');
      }

      print('✅ Manipulation tactics covered: ${allTactics.length} unique tactics');
    });


    test('Trust pattern analysis works', () {
      // Simulate series of results
      final results = [
        TrustCalibrationResult(
          points: 100,
          feedback: 'Perfect',
          accuracy: 'excellent',
          trustCategory: 'well_calibrated',
          calibrationError: 0.1,
          improvementTips: [],
        ),
        TrustCalibrationResult(
          points: -30,
          feedback: 'Too paranoid',
          accuracy: 'overly_paranoid',
          trustCategory: 'very_suspicious',
          calibrationError: 0.4,
          improvementTips: [],
        ),
        TrustCalibrationResult(
          points: -20,
          feedback: 'Too paranoid',
          accuracy: 'overly_paranoid',
          trustCategory: 'very_suspicious',
          calibrationError: 0.3,
          improvementTips: [],
        ),
      ];

      final pattern = TrustCalibrationEngine.analyzeTrustPattern(results);
      expect(pattern, equals(TrustPattern.overlyParanoid));

      final recommendations = TrustCalibrationEngine.getPersonalizedRecommendations(pattern);
      expect(recommendations, isNotEmpty);
      expect(recommendations.first, contains('paranoid'));

      print('✅ Trust pattern analysis functioning');
    });

    test('Balanced mix function works correctly', () {
      final balanced = ShieldUpScenario.getBalancedMix(count: 8);

      expect(balanced.length, equals(8));

      final scamCount = balanced.where((s) => s.isScam).length;
      final legitCount = balanced.where((s) => !s.isScam).length;

      expect(scamCount, equals(4));
      expect(legitCount, equals(4));

      print('✅ Balanced mix function working correctly');
    });

    test('Research sources are properly cited', () {
      final requiredSources = [
        'FBI',
        'FTC',
      ];

      final allSources = allScenarios
          .map((s) => s.researchSource.toLowerCase())
          .toSet();

      for (var source in requiredSources) {
        final hasSource = allSources.any((s) => s.toLowerCase().contains(source.toLowerCase()));
        expect(hasSource, isTrue,
            reason: 'Must cite $source as research source');
      }

      print('✅ Research sources properly cited');
    });

    test('No personal identifying information present', () {
      for (var scenario in allScenarios) {
        // Check victim testimony for PII
        final testimony = scenario.victimTestimony.toLowerCase();

        // Should not contain real names, addresses, etc.
        final piiPatterns = [
          RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
          RegExp(r'\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b'), // Credit card
          RegExp(r'\b[A-Z]{2}\d{5}\b'), // Zip+4
        ];

        for (var pattern in piiPatterns) {
          expect(testimony, isNot(matches(pattern)),
              reason: 'Scenario ${scenario.id} may contain PII');
        }
      }

      print('✅ No PII detected in content');
    });

    test('JSON serialization works correctly', () {
      for (var scenario in allScenarios.take(3)) {
        final json = scenario.toJson();

        expect(json['id'], equals(scenario.id));
        expect(json['isScam'], equals(scenario.isScam));
        expect(json['optimalTrustLevel'], equals(scenario.optimalTrustLevel));
        expect(json['conversation'], isA<List>());
        expect(json['trustScoring'], isA<Map>());

        // Ensure conversation messages serialize correctly
        final conversationJson = json['conversation'] as List;
        expect(conversationJson.length, equals(scenario.conversation.length));
      }

      print('✅ JSON serialization working correctly');
    });

    test('Locked scenario file has valid structure', () async {
      final file = File('assets/research_locked_scenarios.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonData = json.decode(content);

        expect(jsonData['version'], isNotNull);
        expect(jsonData['scenarios'], isA<List>());
        expect(jsonData['statistics'], isA<Map>());
        expect(jsonData['researchSources'], isA<List>());
        expect(jsonData['privacyCompliance'], isA<Map>());

        final scenarios = jsonData['scenarios'] as List;
        expect(scenarios.length, greaterThanOrEqualTo(8));

        // Check statistics match actual content
        final stats = jsonData['statistics'];
        final scamCount = scenarios.where((s) => s['isScam'] == true).length;
        final legitCount = scenarios.where((s) => s['isScam'] == false).length;

        expect(stats['scamScenarios'], equals(scamCount));
        expect(stats['legitimateScenarios'], equals(legitCount));
        expect(stats['scamToLegitimateRatio'], equals('55:45'));

        print('✅ Locked scenario file structure validated');
      } else {
        print('⚠️ Locked scenario file not found, skipping validation');
      }
    });
  });

  group('Educational Content Quality', () {
    test('Scenarios have educational value', () {
      final scenarios = ShieldUpScenario.getAllResearchScenarios();

      for (var scenario in scenarios) {
        // Must have clear explanation
        expect(scenario.explanation.length, greaterThan(50),
            reason: 'Scenario ${scenario.id} needs detailed explanation');

        // Must have actionable guidance
        if (scenario.isScam) {
          expect(scenario.redFlags.length, greaterThanOrEqualTo(3),
              reason: 'Scam ${scenario.id} needs multiple red flags');
        } else {
          expect(scenario.legitimateFlags.length, greaterThanOrEqualTo(3),
              reason: 'Legitimate ${scenario.id} needs multiple positive indicators');
        }

        // Victim testimony should be educational
        expect(scenario.victimTestimony.length, greaterThan(30),
            reason: 'Victim testimony for ${scenario.id} should be substantial');
      }

      print('✅ All scenarios have educational value');
    });

    test('Content is age-appropriate and ethical', () {
      final scenarios = ShieldUpScenario.getAllResearchScenarios();

      for (var scenario in scenarios) {
        final content = '${scenario.conversation.map((m) => m.text).join(' ')} '
                       '${scenario.explanation} ${scenario.victimTestimony}';
        final lowerContent = content.toLowerCase();

        // Should not contain inappropriate content
        final inappropriateTerms = [
          'explicit', 'graphic', 'violent', 'sexual'
        ];

        for (var term in inappropriateTerms) {
          expect(lowerContent, isNot(contains(term)),
              reason: 'Scenario ${scenario.id} contains inappropriate content');
        }
      }

      print('✅ Content is age-appropriate and ethical');
    });
  });
}

