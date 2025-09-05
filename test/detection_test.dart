
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/detection.dart';


void main() {
  group('Detector', () {
    test('should return Info for empty text', () {
      final result = Detector.analyze('');
      expect(result.riskScore, 0.0);
      expect(result.riskLabel, 'Info');
      expect(result.hits, isEmpty);
    });

    test('should detect R001 rule', () {
      final result = Detector.analyze('This is an urgent message');
      expect(result.hits.any((h) => h.id == 'R001'), isTrue);
    });

    test('should detect R010 rule', () {
      final result = Detector.analyze('This is a fraud alert from your bank');
      expect(result.hits.any((h) => h.id == 'R010'), isTrue);
    });

    test('should detect SOCIAL_PROOF_WIN rule', () {
      final result = Detector.analyze('You have won a prize!');
      expect(result.hits.any((h) => h.id == 'SOCIAL_PROOF_WIN'), isTrue);
    });

    test('should detect R020 rule', () {
      final result = Detector.analyze('Click this link: https://example.com');
      expect(result.hits.any((h) => h.id == 'R020'), isTrue);
    });

    test('should detect EMOTION_FEAR rule', () {
      final result = Detector.analyze('Your account has been compromised');
      expect(result.hits.any((h) => h.id == 'EMOTION_FEAR'), isTrue);
    });

    test('should detect NORM_ACT_PAY rule', () {
      final result = Detector.analyze('Your payment is overdue');
      expect(result.hits.any((h) => h.id == 'NORM_ACT_PAY'), isTrue);
    });

    test('should apply COMBO_BANK_FEAR bonus', () {
      final result = Detector.analyze('Urgent fraud alert from your bank, your account is compromised.');
      final authorityBankHit = result.hits.any((h) => h.id == 'R010');
      final emotionFearHit = result.hits.any((h) => h.id == 'EMOTION_FEAR');
      final urgencyHit = result.hits.any((h) => h.id == 'R001');

      expect(authorityBankHit, isTrue);
      expect(emotionFearHit, isTrue);
      expect(urgencyHit, isTrue);

      // 0.3 (R010) + 0.3 (EMOTION_FEAR) + 0.2 (R001) + 0.15 (COMBO) = 0.95
      expect(result.riskScore, closeTo(0.95, 0.01));
      expect(result.riskLabel, 'Strong Warning');
    });

    test('should cap score at 1.0', () {
        final result = Detector.analyze('Urgent fraud alert from your bank, your account is compromised, and you have won a prize. Click this link: https://example.com');
        expect(result.riskScore, 1.0);
    });

    test('should return Caution label for score between 0.5 and 0.79', () {
        final result = Detector.analyze('fraud alert, your payment is overdue');
        // 0.3 (R010) + 0.2 (NORM_ACT_PAY) = 0.5
        expect(result.riskScore, closeTo(0.5, 0.01));
        expect(result.riskLabel, 'Caution');
    });

    test('should return Strong Warning label for score >= 0.8', () {
        final result = Detector.analyze('Urgent fraud alert from your bank, your account is compromised');
        // 0.2 (R001) + 0.3 (R010) + 0.3 (EMOTION_FEAR) + 0.15 (COMBO) = 0.95
        expect(result.riskScore, closeTo(0.95, 0.01));
        expect(result.riskLabel, 'Strong Warning');
    });
  });
}
