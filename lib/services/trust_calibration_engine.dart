import '../data/shieldup_scenarios.dart';

/// Trust Calibration Results
class TrustCalibrationResult {
  final int points;
  final String feedback;
  final String accuracy;
  final String trustCategory;
  final double calibrationError;
  final List<String> improvementTips;

  TrustCalibrationResult({
    required this.points,
    required this.feedback,
    required this.accuracy,
    required this.trustCategory,
    required this.calibrationError,
    required this.improvementTips,
  });
}

/// Trust behavior patterns for user education
enum TrustPattern {
  wellCalibrated,    // Accurate trust judgments
  overlyParanoid,    // Rejects legitimate content
  overlyTrusting,    // Accepts scam content
  inconsistent,      // Mixed accuracy
}

/// Main Trust Calibration Engine
/// Evaluates user trust decisions against research-backed optimal levels
class TrustCalibrationEngine {

  /// Evaluate user's trust level against optimal for scenario
  static TrustCalibrationResult evaluateResponse({
    required double userTrustLevel,    // 0-100 user's trust rating
    required ShieldUpScenario scenario,
    required int timeToDecision,       // Decision time in seconds
  }) {
    final optimal = scenario.optimalTrustLevel;
    final difference = (userTrustLevel - optimal).abs();
    final isScam = scenario.isScam;

    // Determine trust category
    String trustCategory = _getTrustCategory(userTrustLevel);

    // Calculate calibration error
    double calibrationError = difference / 100.0;

    // Get base scoring from scenario's trust scoring table
    int basePoints = _getScenarioPoints(userTrustLevel, scenario);

    // Apply timing bonus/penalty
    int timingAdjustment = _getTimingAdjustment(timeToDecision);

    // Final points
    int finalPoints = basePoints + timingAdjustment;

    // Generate feedback
    String feedback = _generateFeedback(
      userTrustLevel,
      optimal,
      isScam,
      difference,
      timeToDecision,
    );

    // Determine accuracy rating
    String accuracy = _getAccuracyRating(difference, isScam, userTrustLevel, optimal);

    // Get improvement tips
    List<String> tips = _getImprovementTips(userTrustLevel, optimal, isScam, scenario);

    return TrustCalibrationResult(
      points: finalPoints,
      feedback: feedback,
      accuracy: accuracy,
      trustCategory: trustCategory,
      calibrationError: calibrationError,
      improvementTips: tips,
    );
  }

  /// Analyze user's overall trust pattern across multiple scenarios
  static TrustPattern analyzeTrustPattern(List<TrustCalibrationResult> results) {
    if (results.length < 3) return TrustPattern.inconsistent;

    int paranoidCount = 0;
    int trustingCount = 0;
    int wellCalibratedCount = 0;

    for (var result in results) {
      if (result.accuracy == 'overly_paranoid') {
        paranoidCount++;
      } else if (result.accuracy == 'overly_trusting') {
        trustingCount++;
      } else if (result.accuracy == 'excellent' || result.accuracy == 'good') {
        wellCalibratedCount++;
      }
    }

    double total = results.length.toDouble();
    double paranoidRatio = paranoidCount / total;
    double trustingRatio = trustingCount / total;
    double calibratedRatio = wellCalibratedCount / total;

    if (calibratedRatio > 0.6) return TrustPattern.wellCalibrated;
    if (paranoidRatio > 0.6) return TrustPattern.overlyParanoid;
    if (trustingRatio > 0.6) return TrustPattern.overlyTrusting;
    return TrustPattern.inconsistent;
  }

  /// Get personalized training recommendations
  static List<String> getPersonalizedRecommendations(TrustPattern pattern) {
    switch (pattern) {
      case TrustPattern.wellCalibrated:
        return [
          'Excellent trust calibration! Keep practicing with harder scenarios.',
          'Try advanced manipulation detection training.',
          'Consider helping others learn to identify scams.',
        ];

      case TrustPattern.overlyParanoid:
        return [
          'You\'re good at spotting scams, but missing legitimate opportunities.',
          'Practice identifying legitimate communications from real organizations.',
          'Look for official contact methods and security disclaimers.',
          'Remember: not everything is a scam!',
        ];

      case TrustPattern.overlyTrusting:
        return [
          'You\'re at high risk for scams. Focus on red flag recognition.',
          'Always verify urgent requests through independent channels.',
          'Be especially cautious of emotional manipulation.',
          'When in doubt, wait 24 hours before taking action.',
        ];

      case TrustPattern.inconsistent:
        return [
          'Work on developing consistent decision-making criteria.',
          'Focus on the specific red flags and legitimate indicators.',
          'Practice with mixed scenario sets to improve pattern recognition.',
        ];
    }
  }

  // Private helper methods

  static String _getTrustCategory(double trustLevel) {
    if (trustLevel < 25) return 'very_suspicious';
    if (trustLevel < 50) return 'suspicious';
    if (trustLevel < 75) return 'neutral';
    return 'trusting';
  }

  static int _getScenarioPoints(double userTrust, ShieldUpScenario scenario) {
    String category = _getTrustCategory(userTrust);
    return scenario.trustScoring[category]?.round() ?? 0;
  }

  static int _getTimingAdjustment(int timeToDecision) {
    // Bonus for thoughtful decision time, penalty for snap judgments
    if (timeToDecision < 5) return -10;  // Too hasty
    if (timeToDecision < 15) return 0;   // Normal
    if (timeToDecision < 45) return 5;   // Thoughtful
    return -5; // Too slow
  }

  static String _generateFeedback(
    double userTrust,
    double optimal,
    bool isScam,
    double difference,
    int timeToDecision,
  ) {
    if (difference < 15) {
      return 'Perfect calibration! You accurately assessed the risk level.';
    }

    if (isScam && userTrust > optimal + 20) {
      return 'Too trusting! This was a scam designed to steal money/data. Look for red flags.';
    }

    if (!isScam && userTrust < optimal - 20) {
      return 'Too paranoid! This was legitimate. You might miss real opportunities.';
    }

    if (isScam && userTrust < optimal + 15) {
      return 'Good instincts! You spotted the scam. Fine-tune your risk assessment.';
    }

    if (!isScam && userTrust > optimal - 15) {
      return 'Good judgment! You recognized this was legitimate. Trust your verification skills.';
    }

    return 'Consider the specific indicators that make this trustworthy or suspicious.';
  }

  static String _getAccuracyRating(double difference, bool isScam, double userTrust, double optimal) {
    if (difference < 15) return 'excellent';
    if (difference < 30) return 'good';

    if (isScam && userTrust > optimal) return 'overly_trusting';
    if (!isScam && userTrust < optimal) return 'overly_paranoid';

    return 'needs_improvement';
  }

  static List<String> _getImprovementTips(
    double userTrust,
    double optimal,
    bool isScam,
    ShieldUpScenario scenario,
  ) {
    List<String> tips = [];

    if (isScam && userTrust > optimal + 20) {
      tips.addAll([
        'Focus on the red flags: ${scenario.redFlags.join(", ")}',
        'Remember: ${scenario.explanation}',
        'When in doubt, verify through official channels',
      ]);
    }

    if (!isScam && userTrust < optimal - 20) {
      tips.addAll([
        'Look for legitimate indicators: ${scenario.legitimateFlags.join(", ")}',
        'Not everything is a scam - learn to recognize authentic communications',
        'Verify through official websites when unsure',
      ]);
    }

    if (scenario.victimTestimony.isNotEmpty) {
      tips.add('Real experience: "${scenario.victimTestimony}"');
    }

    return tips;
  }

  /// Generate comprehensive trust report
  static Map<String, dynamic> generateTrustReport(List<TrustCalibrationResult> results) {
    if (results.isEmpty) return {};

    var pattern = analyzeTrustPattern(results);
    var recommendations = getPersonalizedRecommendations(pattern);

    // Calculate statistics
    double avgCalibrationError = results
        .map((r) => r.calibrationError)
        .reduce((a, b) => a + b) / results.length;

    int totalPoints = results.map((r) => r.points).reduce((a, b) => a + b);

    Map<String, int> accuracyCounts = {};
    for (var result in results) {
      accuracyCounts[result.accuracy] = (accuracyCounts[result.accuracy] ?? 0) + 1;
    }

    return {
      'trustPattern': pattern.toString(),
      'recommendations': recommendations,
      'averageCalibrationError': avgCalibrationError,
      'totalPoints': totalPoints,
      'accuracyBreakdown': accuracyCounts,
      'scenariosCompleted': results.length,
      'overallGrade': _calculateOverallGrade(avgCalibrationError, totalPoints, results.length),
    };
  }

  static String _calculateOverallGrade(double avgError, int totalPoints, int scenarioCount) {
    double avgPoints = totalPoints / scenarioCount;

    if (avgError < 0.2 && avgPoints > 70) return 'A';
    if (avgError < 0.3 && avgPoints > 50) return 'B';
    if (avgError < 0.4 && avgPoints > 30) return 'C';
    if (avgError < 0.5 && avgPoints > 10) return 'D';
    return 'F';
  }
}