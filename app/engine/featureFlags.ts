// Feature Flags - PRD-02 v2.1
// Runtime configuration for testing and progressive rollout

export interface FeatureFlags {
  // PRD-02 v2.1 features
  trustPressureEnabled: boolean;
  hapticFeedbackEnabled: boolean;
  demoAutoLaunch: boolean;
  debriefEnhanced: boolean;

  // Accessibility features
  screenReaderOptimized: boolean;
  highContrastMode: boolean;
  reducedMotion: boolean;

  // Validation and testing
  strictValidation: boolean;
  debugMode: boolean;
  logTelemetry: boolean;

  // Progressive features (future PRDs)
  adaptiveDifficulty: boolean;
  platformSkins: boolean;
  meaningfulTimers: boolean;
  realisticConsequences: boolean;
  progressiveCurriculum: boolean;
  recoveryTraining: boolean;
  qualityEnforcement: boolean;
}

const DEFAULT_FLAGS: FeatureFlags = {
  // Core PRD-02 features - enabled by default
  trustPressureEnabled: true,
  hapticFeedbackEnabled: true,
  demoAutoLaunch: true,
  debriefEnhanced: true,

  // Accessibility - auto-detect where possible
  screenReaderOptimized: true,
  highContrastMode: false, // Auto-detect from system
  reducedMotion: false,    // Auto-detect from system

  // Development and validation
  strictValidation: true,
  debugMode: false,
  logTelemetry: false, // Always false for privacy

  // Future features - disabled by default
  adaptiveDifficulty: false,
  platformSkins: false,
  meaningfulTimers: false,
  realisticConsequences: false,
  progressiveCurriculum: false,
  recoveryTraining: false,
  qualityEnforcement: false
};

let currentFlags: FeatureFlags = { ...DEFAULT_FLAGS };

export function initializeFeatureFlags(overrides?: Partial<FeatureFlags>) {
  currentFlags = { ...DEFAULT_FLAGS };

  // Auto-detect accessibility preferences
  if (typeof window !== 'undefined') {
    // Detect prefers-reduced-motion
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    currentFlags.reducedMotion = prefersReducedMotion;

    // Detect high contrast mode
    const prefersHighContrast = window.matchMedia('(prefers-contrast: high)').matches;
    currentFlags.highContrastMode = prefersHighContrast;

    // Disable haptics if reduced motion is preferred
    if (prefersReducedMotion) {
      currentFlags.hapticFeedbackEnabled = false;
    }
  }

  // Apply runtime overrides from config
  loadRuntimeConfig();

  // Apply explicit overrides
  if (overrides) {
    currentFlags = { ...currentFlags, ...overrides };
  }

  return currentFlags;
}

function loadRuntimeConfig() {
  // Try to load from runtime.json (Netlify deployments)
  if (typeof window !== 'undefined') {
    fetch('/config/runtime.json')
      .then(response => response.json())
      .then(config => {
        // Map runtime config to feature flags
        if (config.pressureMeterEnabled !== undefined) {
          currentFlags.trustPressureEnabled = config.pressureMeterEnabled;
        }
        if (config.debugMode !== undefined) {
          currentFlags.debugMode = config.debugMode;
        }
        if (config.adaptiveDifficulty !== undefined) {
          currentFlags.adaptiveDifficulty = config.adaptiveDifficulty;
        }
        if (config.platformSkins !== undefined) {
          currentFlags.platformSkins = config.platformSkins;
        }
        if (config.meaningfulTimers !== undefined) {
          currentFlags.meaningfulTimers = config.meaningfulTimers;
        }
        if (config.realisticConsequences !== undefined) {
          currentFlags.realisticConsequences = config.realisticConsequences;
        }
        if (config.progressiveCurriculum !== undefined) {
          currentFlags.progressiveCurriculum = config.progressiveCurriculum;
        }
        if (config.recoveryTraining !== undefined) {
          currentFlags.recoveryTraining = config.recoveryTraining;
        }
        if (config.qualityEnforcement !== undefined) {
          currentFlags.qualityEnforcement = config.qualityEnforcement;
        }
      })
      .catch(() => {
        // Silently fail - runtime config is optional
        console.debug('Runtime config not available, using defaults');
      });
  }
}

export function getFeatureFlags(): Readonly<FeatureFlags> {
  return { ...currentFlags };
}

export function isFeatureEnabled(feature: keyof FeatureFlags): boolean {
  return currentFlags[feature] as boolean;
}

export function updateFeatureFlag(feature: keyof FeatureFlags, enabled: boolean) {
  currentFlags[feature] = enabled as any;
}

// Utility functions for common feature checks
export function shouldUseTrustPressure(): boolean {
  return isFeatureEnabled('trustPressureEnabled');
}

export function shouldUseHaptics(): boolean {
  return isFeatureEnabled('hapticFeedbackEnabled') && !isFeatureEnabled('reducedMotion');
}

export function shouldAutoLaunchDemo(): boolean {
  return isFeatureEnabled('demoAutoLaunch');
}

export function shouldUseEnhancedDebrief(): boolean {
  return isFeatureEnabled('debriefEnhanced');
}

export function shouldOptimizeForScreenReader(): boolean {
  return isFeatureEnabled('screenReaderOptimized');
}

export function shouldUseHighContrast(): boolean {
  return isFeatureEnabled('highContrastMode');
}

export function shouldReduceMotion(): boolean {
  return isFeatureEnabled('reducedMotion');
}

export function isDebugMode(): boolean {
  return isFeatureEnabled('debugMode');
}

export function shouldUseStrictValidation(): boolean {
  return isFeatureEnabled('strictValidation');
}

// Initialize on import
if (typeof window !== 'undefined') {
  initializeFeatureFlags();
}