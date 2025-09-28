# ScamShield GDevelop - Smoke Test Checklist

## Pre-Test Setup
- [ ] GDevelop 5 installed and updated
- [ ] Project opens without errors: `ScamShield-gd/project.json`
- [ ] All assets visible in Project Manager (mascot, bubbles, badges)
- [ ] Preview starts successfully

## Core Game Flow Tests

### 1. Boot & Loading
- [ ] Boot scene displays "Loading scenarios..." text
- [ ] Transitions to Home scene after loading
- [ ] No JavaScript errors in console
- [ ] Global variables populated (Registry.Scenarios)

### 2. Home Scene Navigation
- [ ] Title displays "ScamShield"
- [ ] "Start Training" button visible and clickable
- [ ] Navigation to MenuYouth works
- [ ] Other menu buttons respond (even if not fully implemented)

### 3. PlayScene - Chat Experience
- [ ] Scenario loads with proper background
- [ ] Mascot appears in neutral state (top-left)
- [ ] Chat bubble displays scammer message
- [ ] Reply chips appear for user choices (3 options)
- [ ] Tapping reply chip shows user bubble
- [ ] Mascot changes animation: happy for safe choice, sad for risky
- [ ] Choice feedback displays briefly

### 4. Debrief & Quiz Flow
- [ ] Debrief card slides up with tactic explanation
- [ ] "Continue to Quiz" button works
- [ ] Quiz questions display with multiple choice options
- [ ] Correct/incorrect feedback shows immediately
- [ ] Quiz score calculated properly

### 5. Badge & Achievement System
- [ ] Badge popup appears after quiz completion
- [ ] Correct badge type displays (bronze/silver/gold/star)
- [ ] Badge saved to local storage
- [ ] Return to Home shows last badge earned

### 6. QuickTest (SDAT-10)
- [ ] QuickTest scene loads 10 questions
- [ ] Questions randomized on each run
- [ ] Mix of scam (5) and legitimate (5) scenarios
- [ ] Score summary displays with percentage
- [ ] 3 prevention tips shown after completion
- [ ] Return to Home works

## Accessibility & UX Tests

### 7. Large Text Support
- [ ] Toggle large text setting in menu
- [ ] Chat bubbles expand properly for larger text
- [ ] Reply chips remain tappable (≥48px hit target)
- [ ] No text clipping in UI elements

### 8. Dark Mode (if implemented)
- [ ] Toggle dark/light theme
- [ ] High contrast maintained in both modes
- [ ] Chat bubbles readable in both themes
- [ ] Mascot visible against background

### 9. Privacy & Offline Operation
- [ ] Privacy page displays static content
- [ ] No network requests made (check browser dev tools)
- [ ] Game works with internet disconnected
- [ ] Local storage saves progress only (no PII)

## Content Validation Tests

### 10. Scenario Content
- [ ] Dating scenario (y01) loads and plays completely
- [ ] Sextortion scenario (y02) loads and plays completely
- [ ] All tactic tags display in debrief
- [ ] Quiz questions match scenario content
- [ ] Provenance sources shown

### 11. Error Handling
- [ ] Invalid choice selections handled gracefully
- [ ] Missing asset files don't crash game
- [ ] Corrupted JSON scenarios fail safely
- [ ] Browser refresh preserves progress

## Export & Platform Tests

### 12. Android Export
- [ ] APK builds without errors
- [ ] App installs on Android device/emulator
- [ ] No internet permissions in manifest
- [ ] Game runs offline on mobile
- [ ] Touch interactions work properly

### 13. iOS Export (if available)
- [ ] IPA builds without errors
- [ ] App installs on iOS device/simulator
- [ ] No network capabilities in Info.plist
- [ ] Game runs offline on mobile
- [ ] Touch interactions work properly

## Performance Tests

### 14. Loading & Memory
- [ ] Boot scene loads in <3 seconds
- [ ] Scenario transitions smooth (<500ms)
- [ ] No memory leaks during extended play
- [ ] Asset loading doesn't block UI

### 15. Game Feel
- [ ] Mascot animations feel responsive
- [ ] Chat bubble transitions smooth
- [ ] Reply chip taps have immediate feedback
- [ ] Badge popup feels celebratory

## Final Validation

### 16. Complete User Journey
- [ ] New user: Boot → Home → MenuYouth → Play scenario → Complete → Badge → Home
- [ ] Returning user: Home shows previous badge, can start new scenario
- [ ] Quick test: Complete 10 questions, see score, return to menu
- [ ] Privacy: Can view privacy policy from main menu

## Sign-Off Criteria

All core game flow tests (1-6) must pass ✅  
At least 80% of accessibility tests (7-9) must pass ✅  
All content validation tests (10-11) must pass ✅  
At least one platform export (12 or 13) must pass ✅

**Test Date:** ___________  
**Tested By:** ___________  
**GDevelop Version:** ___________  
**Pass/Fail:** ___________  

**Notes:**