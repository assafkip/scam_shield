import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/detection.dart';

void main() {
  test('R001 urgency', () {
    final r = Detector.analyze('Final warning! Pay within 10 mins.');
    expect(r.hits.any((h) => h.id == 'R001'), true);
  });

  test('R020 shortlink', () {
    final r = Detector.analyze('Check this now: bit.ly/abc');
    expect(r.hits.any((h) => h.id == 'R020'), true);
  });

  test('combo bonus: authority + link', () {
    final r = Detector.analyze('Bank of Gotham: update KYC now: bit.ly/abc');
    // Optionally assert on risk threshold if you expose score function
    expect(r.hits.any((h) => h.id == 'R010'), true);
    expect(r.hits.any((h) => h.id == 'R020'), true);
  });
}