import 'package:flutter_test/flutter_test.dart';
import '../lib/data/shieldup_scenarios.dart';
import '../lib/services/trust_calibration_engine.dart';

/// Simple validation tests to ensure core functionality works
void main() {
  group('Basic Research Content Validation', () {
    test('ShieldUp scenarios load successfully', () {
      final scenarios = ShieldUpScenario.getAllResearchScenarios();
      expect(scenarios.length, greaterThan(5));
      print('✅ Loaded ${scenarios.length} research scenarios');
    });

    test('Scam to legitimate ratio close to 50/50', () {
      final scenarios = ShieldUpScenario.getAllResearchScenarios();
      final scams = scenarios.where((s) => s.isScam).length;
      final legitimate = scenarios.where((s) => !s.isScam).length;

      // For 9 scenarios, expect 4 scams and 5 legitimate (44:56 ratio - close to 50:50)
      expect(scams, equals(4));
      expect(legitimate, equals(5));
      print('✅ Close to 50/50 ratio: $scams scams, $legitimate legitimate (44:56)');
    });

    test('Trust calibration engine works', () {
      final scenarios = ShieldUpScenario.getAllResearchScenarios();
      final scenario = scenarios.first;

      final result = TrustCalibrationEngine.evaluateResponse(
        userTrustLevel: scenario.optimalTrustLevel,
        scenario: scenario,
        timeToDecision: 20,
      );

      expect(result.points, greaterThan(50));
      print('✅ Trust calibration engine working');
    });

    test('Balanced mix function works', () {
      final balanced = ShieldUpScenario.getBalancedMix(count: 8);
      expect(balanced.length, equals(8));

      final scamCount = balanced.where((s) => s.isScam).length;
      final legitCount = balanced.where((s) => !s.isScam).length;

      expect(scamCount, equals(4));
      expect(legitCount, equals(4));
      print('✅ Balanced mix working correctly');
    });

    test('All scenarios have required content', () {
      final scenarios = ShieldUpScenario.getAllResearchScenarios();

      for (var scenario in scenarios) {
        expect(scenario.conversation.length, greaterThan(1));
        expect(scenario.victimTestimony, isNotEmpty);
        expect(scenario.researchSource, isNotEmpty);
        expect(scenario.trustScoring, isNotEmpty);

        if (scenario.isScam) {
          expect(scenario.manipulationTactics, isNotEmpty);
          expect(scenario.redFlags, isNotEmpty);
        } else {
          expect(scenario.legitimateFlags, isNotEmpty);
        }
      }

      print('✅ All scenarios have required content');
    });
  });
}