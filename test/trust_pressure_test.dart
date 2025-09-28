/// Test suite for PRD-02 trust/pressure tracking
/// Validates trust score calculation and pressure level updates

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/conversation/conversation.dart';

void main() {
  group('Trust and Pressure Tracking Tests', () {
    late ConversationState initialState;

    setUp(() {
      initialState = const ConversationState(
        conversationId: 'test_001',
        currentStepId: 's1',
      );
    });

    test('GIVEN choices with trustHints 0.9 and 0.3, WHEN user picks both, THEN trustScore=0.6', () {
      // Create choices with specific trust hints
      final choice1 = ConversationChoice(
        id: 'choice1',
        label: 'High trust choice',
        safe: false,
        next: 's2',
        trustHint: 0.9,
        pressureDelta: 0.0,
      );

      final choice2 = ConversationChoice(
        id: 'choice2',
        label: 'Low trust choice',
        safe: true,
        next: 's3',
        trustHint: 0.3,
        pressureDelta: 0.0,
      );

      // Apply first choice
      final state1 = initialState.applyChoice(choice1, 's1');
      expect(state1.currentTrust, equals(0.9));

      // Apply second choice
      final state2 = state1.applyChoice(choice2, 's2');

      // Trust should be average: (0.9 + 0.3) / 2 = 0.6
      expect(state2.currentTrust, equals(0.6));
      expect(state2.trustScorePercentage, equals(60.0));
    });

    test('GIVEN pressureDeltas +2, -1, THEN pressureLevel updates accordingly', () {
      final choice1 = ConversationChoice(
        id: 'choice1',
        label: 'Increase pressure',
        safe: false,
        next: 's2',
        trustHint: 0.5,
        pressureDelta: 2.0,
      );

      final choice2 = ConversationChoice(
        id: 'choice2',
        label: 'Decrease pressure',
        safe: true,
        next: 's3',
        trustHint: 0.5,
        pressureDelta: -1.0,
      );

      // Initial pressure should be 0
      expect(initialState.currentPressure, equals(0.0));

      // Apply first choice (+2)
      final state1 = initialState.applyChoice(choice1, 's1');
      expect(state1.currentPressure, equals(2.0));

      // Apply second choice (-1)
      final state2 = state1.applyChoice(choice2, 's2');
      expect(state2.currentPressure, equals(1.0));
    });

    test('pressure level is clamped between 0.0 and 100.0', () {
      final highPressureChoice = ConversationChoice(
        id: 'high',
        label: 'Extreme pressure',
        safe: false,
        next: 's2',
        trustHint: 0.5,
        pressureDelta: 150.0, // Would exceed 100
      );

      final lowPressureChoice = ConversationChoice(
        id: 'low',
        label: 'Negative pressure',
        safe: true,
        next: 's3',
        trustHint: 0.5,
        pressureDelta: -200.0, // Would go below 0
      );

      // Test upper bound
      final highState = initialState.applyChoice(highPressureChoice, 's1');
      expect(highState.currentPressure, equals(100.0));

      // Test lower bound
      final lowState = highState.applyChoice(lowPressureChoice, 's2');
      expect(lowState.currentPressure, equals(0.0));
    });

    test('trust history is properly maintained', () {
      final choice1 = ConversationChoice(
        id: 'choice1',
        label: 'First choice',
        safe: true,
        next: 's2',
        trustHint: 0.8,
        pressureDelta: 0.0,
      );

      final choice2 = ConversationChoice(
        id: 'choice2',
        label: 'Second choice',
        safe: false,
        next: 's3',
        trustHint: 0.4,
        pressureDelta: 0.0,
      );

      final choice3 = ConversationChoice(
        id: 'choice3',
        label: 'Third choice',
        safe: true,
        next: 's4',
        trustHint: 0.6,
        pressureDelta: 0.0,
      );

      // Apply choices sequentially
      final state1 = initialState.applyChoice(choice1, 's1');
      final state2 = state1.applyChoice(choice2, 's2');
      final state3 = state2.applyChoice(choice3, 's3');

      // Check trust history
      expect(state3.trustHistory, equals([0.8, 0.4, 0.6]));

      // Check final trust score: (0.8 + 0.4 + 0.6) / 3 = 0.6
      expect(state3.currentTrust, closeTo(0.6, 0.001));
    });

    test('pressure trace is properly recorded', () {
      final choice1 = ConversationChoice(
        id: 'choice1',
        label: 'First choice',
        safe: false,
        next: 's2',
        trustHint: 0.5,
        pressureDelta: 5.0,
      );

      final choice2 = ConversationChoice(
        id: 'choice2',
        label: 'Second choice',
        safe: true,
        next: 's3',
        trustHint: 0.5,
        pressureDelta: -3.0,
      );

      // Apply choices
      final state1 = initialState.applyChoice(choice1, 's1');
      final state2 = state1.applyChoice(choice2, 's2');

      // Check pressure trace
      expect(state2.pressureTrace.length, equals(2));

      final trace1 = state2.pressureTrace[0];
      expect(trace1.stepId, equals('s1'));
      expect(trace1.choiceId, equals('choice1'));
      expect(trace1.pressureDelta, equals(5.0));
      expect(trace1.newPressureLevel, equals(5.0));

      final trace2 = state2.pressureTrace[1];
      expect(trace2.stepId, equals('s2'));
      expect(trace2.choiceId, equals('choice2'));
      expect(trace2.pressureDelta, equals(-3.0));
      expect(trace2.newPressureLevel, equals(2.0));
    });

    test('trust analysis provides correct feedback', () {
      // Test high trust scenario
      final highTrustChoice = ConversationChoice(
        id: 'high_trust',
        label: 'I trust completely',
        safe: false,
        next: 's2',
        trustHint: 0.9,
        pressureDelta: 0.0,
      );

      final highTrustState = initialState.applyChoice(highTrustChoice, 's1');
      expect(highTrustState.trustAnalysis, contains('trusted too easily'));
      expect(highTrustState.trustAnalysis, contains('90%'));

      // Test low trust scenario
      final lowTrustChoice = ConversationChoice(
        id: 'low_trust',
        label: 'I don\'t trust this',
        safe: true,
        next: 's2',
        trustHint: 0.2,
        pressureDelta: 0.0,
      );

      final lowTrustState = initialState.applyChoice(lowTrustChoice, 's1');
      expect(lowTrustState.trustAnalysis, contains('very cautious'));
      expect(lowTrustState.trustAnalysis, contains('20%'));

      // Test balanced trust scenario
      final balancedTrustChoice = ConversationChoice(
        id: 'balanced_trust',
        label: 'I\'m somewhat cautious',
        safe: true,
        next: 's2',
        trustHint: 0.5,
        pressureDelta: 0.0,
      );

      final balancedTrustState = initialState.applyChoice(balancedTrustChoice, 's1');
      expect(balancedTrustState.trustAnalysis, contains('balanced trust'));
      expect(balancedTrustState.trustAnalysis, contains('50%'));
    });

    test('pressure analysis provides correct feedback', () {
      final increaseChoice = ConversationChoice(
        id: 'increase1',
        label: 'Pressure increase',
        safe: false,
        next: 's2',
        trustHint: 0.5,
        pressureDelta: 5.0,
      );

      final decreaseChoice = ConversationChoice(
        id: 'decrease1',
        label: 'Pressure decrease',
        safe: true,
        next: 's3',
        trustHint: 0.5,
        pressureDelta: -2.0,
      );

      final increaseChoice2 = ConversationChoice(
        id: 'increase2',
        label: 'Another increase',
        safe: false,
        next: 's4',
        trustHint: 0.5,
        pressureDelta: 3.0,
      );

      // Apply choices to create pressure pattern
      final state1 = initialState.applyChoice(increaseChoice, 's1');
      final state2 = state1.applyChoice(decreaseChoice, 's2');
      final state3 = state2.applyChoice(increaseChoice2, 's3');

      // Should have 2 increases and 1 decrease
      final analysis = state3.pressureAnalysis;
      expect(analysis, contains('escalated pressure 2 times'));
      expect(analysis, contains('resisted 1 times'));
    });

    test('default legacy choice values work correctly', () {
      final legacyChoice = ConversationChoice(
        id: 'legacy',
        label: 'Legacy choice',
        safe: true,
        next: 's2',
        // Using default values: trustHint=0.5, pressureDelta=0.0
      );

      final state = initialState.applyChoice(legacyChoice, 's1');

      expect(state.currentTrust, equals(0.5));
      expect(state.currentPressure, equals(0.0));
    });

    test('state immutability is maintained', () {
      final choice = ConversationChoice(
        id: 'test_choice',
        label: 'Test choice',
        safe: true,
        next: 's2',
        trustHint: 0.7,
        pressureDelta: 5.0,
      );

      final newState = initialState.applyChoice(choice, 's1');

      // Original state should remain unchanged
      expect(initialState.currentTrust, equals(0.5));
      expect(initialState.currentPressure, equals(0.0));
      expect(initialState.trustHistory, isEmpty);
      expect(initialState.pressureTrace, isEmpty);

      // New state should have updated values
      expect(newState.currentTrust, equals(0.7));
      expect(newState.currentPressure, equals(5.0));
      expect(newState.trustHistory, equals([0.7]));
      expect(newState.pressureTrace.length, equals(1));
    });
  });
}