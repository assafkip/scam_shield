/// Feature flag system for PRD-01 and future rollouts
/// Enables gradual deployment and A/B testing

class FeatureFlags {
  static const _prefs = <String, bool>{
    'unified_conversation_pilot': false,
    'implicit_trust_system': false,
    'adaptive_difficulty': false,
    'deep_scenarios_pilot': false,
    'platform_skins': false,
    'meaningful_timers': false,
    'realistic_consequences': false,
    'progressive_curriculum': false,
    'recovery_training': false,
    'quality_enforcement': false,
  };

  /// PRD-01: Unified conversation engine pilot
  static bool get useUnifiedEngine =>
      _getFlag('unified_conversation_pilot');

  /// Whitelisted scenarios for unified engine testing
  static const whitelistScenarioIds = [
    'sample_001', // Test scenario
    'y01_dating', // Research scenario if available
    'ad_001', // Adult scenario if available
  ];

  /// Check if scenario is whitelisted for unified engine
  static bool isScenarioWhitelisted(String scenarioId) {
    return whitelistScenarioIds.contains(scenarioId);
  }

  /// Should use unified engine for this scenario
  static bool shouldUseUnifiedEngine(String scenarioId) {
    return useUnifiedEngine && isScenarioWhitelisted(scenarioId);
  }

  /// PRD-02: Trust from choices system
  static bool get useImplicitTrust =>
      _getFlag('implicit_trust_system');

  /// PRD-03: Adaptive difficulty routing
  static bool get useAdaptiveDifficulty =>
      _getFlag('adaptive_difficulty');

  /// PRD-04: Deep scenarios pilot
  static bool get useDeepScenarios =>
      _getFlag('deep_scenarios_pilot');

  /// PRD-05: Platform authenticity skins
  static bool get usePlatformSkins =>
      _getFlag('platform_skins');

  /// PRD-06: Meaningful timers and social proof
  static bool get useMeaningfulTimers =>
      _getFlag('meaningful_timers');

  /// PRD-07: Realistic consequences and replay
  static bool get useRealisticConsequences =>
      _getFlag('realistic_consequences');

  /// PRD-08: Progressive learning curriculum
  static bool get useProgressiveCurriculum =>
      _getFlag('progressive_curriculum');

  /// PRD-09: Recovery training
  static bool get useRecoveryTraining =>
      _getFlag('recovery_training');

  /// PRD-10: Quality enforcement and accessibility
  static bool get useQualityEnforcement =>
      _getFlag('quality_enforcement');

  /// Internal flag getter with default fallback
  static bool _getFlag(String flagName) {
    // In development, can be overridden via environment or debug settings
    if (_isDebugMode()) {
      final override = _getDebugOverride(flagName);
      if (override != null) return override;
    }

    return _prefs[flagName] ?? false;
  }

  /// Check if running in debug mode
  static bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Get debug override for testing (can be set via environment)
  static bool? _getDebugOverride(String flagName) {
    // For testing purposes, allow enabling unified engine in debug
    if (flagName == 'unified_conversation_pilot') {
      return true; // Enable for development
    }
    return null;
  }

  /// Override flag value (for testing only)
  static final Map<String, bool> _overrides = {};

  static void setFlagForTesting(String flagName, bool value) {
    assert(_isDebugMode(), 'Flag overrides only allowed in debug mode');
    _overrides[flagName] = value;
  }

  static void clearTestingOverrides() {
    assert(_isDebugMode(), 'Flag overrides only allowed in debug mode');
    _overrides.clear();
  }

  /// Get all flag states for debugging
  static Map<String, bool> getAllFlags() {
    final result = <String, bool>{};
    for (final flagName in _prefs.keys) {
      result[flagName] = _getFlag(flagName);
    }
    return result;
  }

}

/// Gradual rollout configuration
class RolloutConfig {
  static const int pilotUserPercentage = 10;
  static const int betaUserPercentage = 25;
  static const int fullRolloutPercentage = 100;

  /// Check if user is in pilot group (simple hash-based assignment)
  static bool isUserInPilot(String userId) {
    final hash = userId.hashCode.abs();
    return (hash % 100) < pilotUserPercentage;
  }

  /// Check if user is in beta group
  static bool isUserInBeta(String userId) {
    final hash = userId.hashCode.abs();
    return (hash % 100) < betaUserPercentage;
  }
}

/// Fallback behavior configuration
class FallbackConfig {
  /// What to do if unified engine fails to load a scenario
  static const fallbackToLegacy = true;

  /// Show error dialog if all engines fail
  static const showErrorDialog = true;

  /// Default error message
  static const errorMessage = 'This training scenario is temporarily unavailable. Please try another one.';
}