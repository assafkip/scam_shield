# iOS Build and Release Setup

## Prerequisites
- macOS with Xcode 15+ installed
- iOS Developer Program membership
- Apple Developer account with app provisioning
- Flutter configured for iOS development

## Step 1: Configure iOS Project Settings

### Update Bundle Identifier
Open `ios/Runner.xcodeproj` in Xcode:

1. **Target Settings**: Runner → General
2. **Bundle Identifier**: Change from `com.example.scamshield` to `com.scamshield.app`
3. **Version**: Set to match Flutter version (pubspec.yaml)
4. **Minimum Deployment**: iOS 12.0 (Flutter minimum)

### Configure Code Signing
1. **Team**: Select your Apple Developer account
2. **Signing Certificate**: Automatic signing recommended
3. **Provisioning Profile**: Let Xcode manage automatically

## Step 2: Create App Store Connect Entry

### App Information
- **App Name**: ScamShield
- **Bundle ID**: com.scamshield.app
- **SKU**: scamshield-app-ios
- **Primary Language**: English (U.S.)

### App Categories
- **Primary**: Education
- **Secondary**: Reference (optional)

### Age Rating
- **Age Rating**: 4+ (suitable for all ages)
- **Content Warnings**: None (educational content only)

## Step 3: iOS Build Configuration

### Release Build Settings
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Output location:
# build/ios/iphoneos/Runner.app
```

### Archive for App Store
1. **Open Xcode**: `ios/Runner.xcodeproj`
2. **Select Device**: Any iOS Device (arm64)
3. **Product → Archive**: Build release archive
4. **Organizer**: Upload to App Store Connect

## Step 4: App Store Assets

### Required iOS Screenshots
- **6.7" iPhone**: 1290 × 2796 pixels (iPhone 14 Pro Max)
- **6.5" iPhone**: 1242 × 2688 pixels (iPhone 11 Pro Max)
- **5.5" iPhone**: 1242 × 2208 pixels (iPhone 8 Plus)
- **12.9" iPad Pro**: 2048 × 2732 pixels
- **11" iPad Pro**: 1668 × 2388 pixels

### App Icon Requirements
- **App Store**: 1024 × 1024 pixels PNG
- **Device Icons**: Generated from Assets.xcassets
- **No transparency**: Solid background required

### Privacy Declarations
Copy from existing documentation:
- No data collection
- No tracking
- Offline-only operation
- COPPA compliant (under 13 users)

## Step 5: TestFlight Internal Testing

### Upload Build
```bash
# After archive in Xcode:
# 1. Validate app → No issues
# 2. Distribute app → App Store Connect
# 3. Upload → Processing takes 10-30 minutes
```

### TestFlight Configuration
- **Beta App Description**: Copy from store_listing.md
- **Test Information**: "Internal testing for release candidate"
- **Test Groups**: Create "Internal Team" group
- **Testers**: Add team email addresses

## Step 6: App Store Review Preparation

### Required Information
- **App Description**: Use finalized store_listing.md content
- **Keywords**: scam, education, safety, training, youth
- **Support URL**: https://github.com/scamshield/app (or company site)
- **Privacy Policy URL**: Host PRIVACY.md content

### Review Notes
```
This app is an educational scam awareness training tool designed for youth. 
It operates completely offline with no data collection. All content is 
pre-loaded educational scenarios. No user data is transmitted or stored.

Key features:
- Interactive scam scenario training
- SDAT (Scam Detection Assessment Tool) quiz
- Progress tracking (local device only)
- Achievement system for engagement

Testing account: Not required (no user accounts)
Special instructions: App works fully offline
```

## Step 7: Release Checklist

### Pre-Submission
- [ ] Bundle ID matches Android package name concept
- [ ] Version number consistent across platforms
- [ ] All placeholder assets replaced with final graphics
- [ ] Privacy policy hosted and accessible
- [ ] App Store description finalized

### Technical Verification
- [ ] iOS build compiles without warnings
- [ ] App launches on iOS 12+ devices
- [ ] All training scenarios load correctly
- [ ] SDAT quiz functions properly
- [ ] No crashes during normal usage

### Store Compliance
- [ ] Age rating appropriate (4+)
- [ ] Privacy declarations accurate
- [ ] No data collection verified
- [ ] COPPA compliance documented
- [ ] Educational content guidelines met

## Troubleshooting

### Common Build Issues

**Code signing errors:**
- Verify Apple Developer account active
- Check provisioning profile validity
- Ensure bundle ID matches App Store Connect

**Archive upload fails:**
- Check for missing required device architectures
- Verify minimum iOS version compatibility
- Review Xcode organizer validation errors

**App Store rejection:**
- Review rejection email carefully
- Update privacy declarations if needed
- Ensure all assets meet quality requirements

### Performance Optimization
- Enable bitcode for app size reduction
- Review asset sizes and compression
- Test on older devices (iPhone 8, iPad 6th gen)

## File Structure
```
ios/
├── Runner.xcodeproj (Xcode project)
├── Runner/
│   ├── Info.plist (app configuration)
│   └── Assets.xcassets/ (icons and assets)
├── Podfile (dependency management)
└── Runner.xcworkspace (Cocoapods workspace)
```

## Next Steps After iOS Release
1. **Monitor**: App Store Connect analytics and reviews
2. **Update**: Regular content updates via app updates
3. **Feedback**: Collect user feedback through App Store reviews
4. **Performance**: Monitor crash reports and performance metrics

## Store Launch Timeline
- **Week 1**: Upload to TestFlight, internal testing
- **Week 2**: Fix any critical issues, prepare App Store submission
- **Week 3**: Submit for App Store review (5-7 day review)
- **Week 4**: Release to App Store (if approved)