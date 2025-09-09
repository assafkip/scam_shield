# Screenshot Capture Guide (MVP 0.6)

## Prerequisites
- Flutter app running on Android device/emulator or iOS simulator
- Screen resolution: 1080x1920 (Android) or equivalent iOS dimensions
- Device language: English
- Fresh app state (clear data before capture)

## Screenshot Specification

### 1. Home Screen (screenshot_01_home.png)
**Path**: Main menu after app launch
**Elements to show**:
- App logo/title
- Main navigation buttons: "Training", "Youth Scenarios", "SDAT Quiz"
- Companion mascot in neutral state
- Clean, welcoming interface

**Capture steps**:
1. Launch app
2. Wait for home screen to fully load
3. Ensure companion is visible
4. Capture full screen

### 2. Training Scenario (screenshot_02_scenario.png)  
**Path**: Training → Youth Scenarios → y01_dating → choice step
**Elements to show**:
- Chat-style message bubble with scam content
- Multiple choice buttons (user responses)
- Scenario context
- Professional UI styling

**Capture steps**:
1. Navigate: Home → Training → Youth Scenarios
2. Start y01_dating scenario
3. Advance to first choice step
4. Capture showing scam message + choice options

### 3. Companion Feedback (screenshot_03_feedback.png)
**Path**: After making a choice in scenario
**Elements to show**:
- Companion mascot reaction (happy for safe choice, concerned for unsafe)
- Feedback message explaining the choice
- Clear visual feedback system

**Capture steps**:
1. Continue from screenshot 2
2. Select a choice option
3. Wait for feedback state to load
4. Capture companion + feedback message

### 4. Debrief & Tactic Learning (screenshot_04_debrief.png)
**Path**: Continue through scenario to debrief
**Elements to show**:
- Detailed explanation of scam tactics
- Educational content about manipulation techniques
- Clear, informative layout

**Capture steps**:
1. Continue from feedback screen
2. Tap "Continue" to reach debrief
3. Capture full debrief explanation

### 5. Achievement Badge (screenshot_05_badge.png)
**Path**: Complete scenario to see badge award
**Elements to show**:
- Badge award modal/dialog
- Badge type (Bronze/Silver/Gold/Star)
- Achievement celebration UI

**Capture steps**:
1. Complete full scenario flow
2. View badge award screen
3. Capture badge presentation

## Technical Requirements

### Image Specifications
- **Format**: PNG (24-bit with transparency)
- **Android**: 1080x1920 pixels minimum
- **iOS**: 1290x2796 pixels (iPhone 14 Pro Max equivalent)
- **Quality**: High resolution, crisp text
- **Naming**: Use exact names from store_listing.md

### Editing Guidelines
- No device frames (raw screen content only)
- Ensure text is legible at thumbnail size
- Maintain aspect ratio consistency
- Remove any test/debug overlays

## Asset Placeholders Status

**Current Status**: All screenshot files are 0-byte placeholders
**Location**: `/assets/images/screenshots/`
**Next Steps**: 
1. Install APK on test device
2. Follow capture steps above
3. Edit and optimize images
4. Replace placeholder files

## Quality Checklist
- [ ] All screenshots captured at consistent quality
- [ ] No personal information visible in scenarios
- [ ] UI elements clearly visible and professional
- [ ] Screenshots demonstrate key app features
- [ ] Image dimensions meet store requirements
- [ ] Files properly named and formatted