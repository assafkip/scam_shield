import 'package:flutter/services.dart';

class HapticHelper {
  /// Light haptic feedback for button taps
  static void lightImpact() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not supported on this platform
    }
  }

  /// Medium haptic feedback for selections
  static void mediumImpact() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not supported on this platform
    }
  }

  /// Heavy haptic feedback for important actions
  static void heavyImpact() {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not supported on this platform
    }
  }

  /// Selection click for UI navigation
  static void selectionClick() {
    try {
      HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not supported on this platform
    }
  }

  /// Vibrate for notifications and alerts
  static void vibrate() {
    try {
      HapticFeedback.vibrate();
    } catch (e) {
      // Haptic feedback not supported on this platform
    }
  }
}