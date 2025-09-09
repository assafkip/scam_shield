# QA Checklist

## 1. Unit & Integration Tests

- [ ] **Unit Test Coverage:** Ensure `test/training_engine_test.dart` has comprehensive coverage of the scenario engine (state transitions, choices, feedback, recall). Target: ≥90%.
- [ ] **Content Integrity Tests:** Verify that the tests for content integrity (unique IDs, >=2 choices per scenario) are passing.
- [ ] **Run all tests:** `flutter test` must pass with no errors.

## 2. Manual Test Matrix

| Platform | Test Case | Expected Result | Pass/Fail |
|---|---|---|---|
| iOS Simulator | Launch app | App opens <2s | |
| Android Emulator | Launch app | App opens <2s | |
| iOS Simulator | Navigate to Training | Training screen loads | |
| Android Emulator | Navigate to Training | Training screen loads | |
| iOS Simulator | Complete a scenario | Flow works as expected | |
| Android Emulator | Complete a scenario | Flow works as expected | |
| iOS Simulator | Large Fonts | UI is readable and not broken | |
| Android Emulator | Large Fonts | UI is readable and not broken | |
| iOS Simulator | Dark Mode | UI is readable and not broken | |
| Android Emulator | Dark Mode | UI is readable and not broken | |

## 3. Accessibility Pass

- [ ] **VoiceOver (iOS):** Navigate the app using VoiceOver. All buttons and text should be clearly announced.
- [ ] **TalkBack (Android):** Navigate the app using TalkBack. All buttons and text should be clearly announced.

## 4. Performance Check

- [ ] **App Open Time:** App should open in under 2 seconds on a mid-tier device.
- [ ] **Scenario Load Time:** Scenarios should load in under 1 second.
- [ ] **No jank:** The app should be smooth with no noticeable jank during animations or transitions.
