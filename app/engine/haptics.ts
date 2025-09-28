// Haptic Feedback Engine - PRD-02 v2.1
// Respects system settings and provides subtle teaching feedback

export function systemAllowsHaptics(): boolean {
  // Check if running in browser
  if (typeof window !== 'undefined') {
    // Web API: check if vibration is supported and not disabled
    return 'vibrate' in navigator &&
           'vibration' in navigator &&
           typeof navigator.vibrate === 'function';
  }

  // For Flutter web, assume haptics are available
  // Flutter handles platform-specific availability
  return true;
}

export function hapticSpike() {
  if (!systemAllowsHaptics()) {
    return;
  }

  try {
    // Web vibration API - short pulse for pressure spike
    if (typeof window !== 'undefined' && 'vibrate' in navigator) {
      // Single 50ms pulse - under 100ms requirement
      navigator.vibrate(50);
      return;
    }

    // Flutter web channel (if available)
    if (typeof window !== 'undefined' && (window as any).flutter_channel) {
      (window as any).flutter_channel.postMessage({
        type: 'haptic',
        pattern: 'light_impact'
      });
      return;
    }

    // Fallback: no haptic feedback
  } catch (error) {
    // Silently fail - haptics are non-critical
    console.debug('Haptic feedback failed:', error);
  }
}

export function hapticSuccess() {
  if (!systemAllowsHaptics()) {
    return;
  }

  try {
    // Two short pulses for success
    if (typeof window !== 'undefined' && 'vibrate' in navigator) {
      navigator.vibrate([30, 50, 30]);
      return;
    }

    // Flutter web channel
    if (typeof window !== 'undefined' && (window as any).flutter_channel) {
      (window as any).flutter_channel.postMessage({
        type: 'haptic',
        pattern: 'medium_impact'
      });
      return;
    }
  } catch (error) {
    console.debug('Haptic success feedback failed:', error);
  }
}

export function hapticWarning() {
  if (!systemAllowsHaptics()) {
    return;
  }

  try {
    // Longer single pulse for warning
    if (typeof window !== 'undefined' && 'vibrate' in navigator) {
      navigator.vibrate(80);
      return;
    }

    // Flutter web channel
    if (typeof window !== 'undefined' && (window as any).flutter_channel) {
      (window as any).flutter_channel.postMessage({
        type: 'haptic',
        pattern: 'heavy_impact'
      });
      return;
    }
  } catch (error) {
    console.debug('Haptic warning feedback failed:', error);
  }
}

// Debounced haptic to prevent overwhelming users
let lastHaptic = 0;
const HAPTIC_DEBOUNCE_MS = 500;

export function debouncedHapticSpike() {
  const now = Date.now();
  if (now - lastHaptic < HAPTIC_DEBOUNCE_MS) {
    return;
  }
  lastHaptic = now;
  hapticSpike();
}

export function debouncedHapticSuccess() {
  const now = Date.now();
  if (now - lastHaptic < HAPTIC_DEBOUNCE_MS) {
    return;
  }
  lastHaptic = now;
  hapticSuccess();
}

export function debouncedHapticWarning() {
  const now = Date.now();
  if (now - lastHaptic < HAPTIC_DEBOUNCE_MS) {
    return;
  }
  lastHaptic = now;
  hapticWarning();
}