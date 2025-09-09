# ScamShield — PRD v0.5 (Pre-Release)

## Problem Statement
ScamShield MVP 0.4 is feature-complete with youth-focused content and SDAT quiz. Now we need to prepare for Play Store internal testing and eventual public launch.

## Target Users
- Internal testers (initial validation)
- Play Store review team (compliance)
- Early access users (feedback collection)

## Non-Goals
- New features or content changes
- UI/UX modifications
- Additional permissions or dependencies
- Analytics or telemetry implementation

## Success Metrics (MVP 0.5)
- **T1**: Successful AAB build with release signing
- **T2**: All store assets generated and validated
- **T3**: Manual QA checklist 100% pass rate
- **T4**: Play Console Data Safety form complete
- **T5**: Privacy policy hosted and accessible

## MVP 0.5 Features (Release Prep Only)

### Store Assets & Documentation
- **Screenshots**: Home, scenario, debrief, badge, SDAT quiz (5 total)
- **App icon**: Final 1024x1024 for stores + adaptive icons for Android
- **Feature graphic**: 1024x500 for Play Store
- **Store listing**: Updated with screenshot references and final copy
- **Privacy policy**: Hosted version with contact details

### Build & Signing
- **Android**: Signed AAB with release keystore
- **Gradle configuration**: Release build optimization
- **Version management**: Proper version codes and names
- **iOS prep**: Archive documentation (future use)

### Quality Assurance
- **Automated testing**: All existing tests pass
- **Manual testing**: Complete QA checklist execution
- **Accessibility**: VoiceOver, TalkBack, large text, dark mode
- **Device compatibility**: Android emulator + iOS simulator validation
- **Performance**: No memory leaks, smooth animations

### Compliance & Legal
- **Data Safety**: Play Console form completion
- **Privacy labels**: App Store privacy configuration
- **Age rating**: Content rating justification
- **Legal review**: Terms and conditions (if required)

## Release Checklist

### Pre-Build
- [ ] All tests passing (`flutter test`)
- [ ] Analyzer clean (`flutter analyze`)
- [ ] Assets present (screenshots, icons, graphics)
- [ ] Documentation updated (store listing, privacy)

### Build & Sign
- [ ] Android keystore generated (local only)
- [ ] AAB built successfully (`flutter build appbundle --release`)
- [ ] Build size under 150MB
- [ ] iOS archive prepared (documentation)

### QA & Testing
- [ ] Manual QA checklist executed
- [ ] Accessibility testing complete
- [ ] Device compatibility verified
- [ ] Performance benchmarks met

### Store Preparation
- [ ] Play Console app created
- [ ] Data Safety form submitted
- [ ] Store listing copy finalized
- [ ] Screenshots uploaded
- [ ] Internal testing track configured

## Technical Requirements

### Build Configuration
- **Target SDK**: Android 34 (latest stable)
- **Min SDK**: Android 21 (covers 95%+ of devices)
- **Flutter version**: Stable channel (3.x latest)
- **Build mode**: Release with obfuscation
- **Signing**: SHA-256 with 2048-bit RSA key

### Asset Requirements
- **App icon**: 1024x1024 PNG, transparent background
- **Adaptive icon**: Foreground + background layers
- **Screenshots**: 5 screens, 1080x1920 or higher
- **Feature graphic**: 1024x500 JPG, no text overlay
- **All assets**: Optimized for size, high quality

### Performance Targets
- **App size**: Under 50MB installed
- **Cold start**: Under 3 seconds
- **Memory usage**: Under 100MB during gameplay
- **Battery impact**: Minimal (no background processing)

## Risk Mitigation

### Store Rejection Risks
- **Content review**: All scenarios are educational, non-explicit
- **Privacy compliance**: Zero data collection clearly documented
- **Technical issues**: Comprehensive QA before submission

### Build Risks
- **Signing issues**: Local keystore backup and documentation
- **Size limits**: Asset optimization and unused code removal
- **Compatibility**: Testing across Android versions and screen sizes

### Timeline Risks
- **Review delays**: Buffer time built into schedule
- **Bug discovery**: Prioritized fix list with severity levels
- **Asset creation**: Templates and guidelines prepared

## Post-0.5 Next Steps
1. **Submit to Play Console** internal testing track
2. **Validate installation** on real devices
3. **Collect tester feedback** and iterate
4. **Prepare production rollout** (staged release)
5. **iOS submission prep** (separate track)

## Dependencies & Assumptions
- **External**: Play Console account access, signing certificates
- **Internal**: All MVP 0.4 features stable and tested
- **Timeline**: 1 week for complete release prep
- **Resources**: Access to Android/iOS test devices or emulators