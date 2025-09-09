# Play Store Upload Guide (MVP 0.6)

## Build Verification ✅

**AAB Generated**: `build/app/outputs/bundle/release/app-release.aab`
- **Size**: 39.1 MB
- **Format**: Valid Android App Bundle (ZIP archive)
- **Signing**: Debug signed (suitable for internal testing)
- **Build Date**: 2025-01-09

## Upload Process

### 1. Google Play Console Access
**URL**: https://play.google.com/console
**Account**: [Developer account with ScamShield app created]

### 2. Internal Testing Track Upload
**Navigation**: 
1. Play Console → ScamShield app
2. Release → Testing → Internal testing
3. Create new release

**Upload Steps**:
```
1. Upload AAB: Select app-release.aab (39.1MB)
2. Release name: "MVP 0.6 - Launch Readiness"  
3. Release notes: "Final QA build with null-safe parsing, 90.9% test coverage"
4. Save → Review → Start rollout to internal testing
```

### 3. Internal Tester Setup
**Test Groups**: 
- "ScamShield Team" (internal developers)
- "Beta Testers" (external volunteers)

**Testers to invite**:
- Development team emails
- QA volunteers  
- Target demographic representatives

### 4. Installation Verification

**Test checklist for internal testers**:
- [ ] App installs successfully from Play Store
- [ ] Launches without crashes
- [ ] Youth scenarios load and play correctly
- [ ] SDAT quiz functions properly  
- [ ] UI elements render correctly
- [ ] Offline functionality confirmed
- [ ] No performance issues during gameplay

## Staged Rollout Plan

### Phase 1: Internal Testing (Week 1)
- **Audience**: Development team + 5-10 beta testers
- **Goal**: Verify installation and core functionality
- **Success criteria**: No critical bugs, positive feedback

### Phase 2: Closed Testing (Week 2)  
- **Audience**: Expanded to 50-100 testers
- **Goal**: Broader device compatibility testing
- **Success criteria**: <2% crash rate, no blocking issues

### Phase 3: Production Rollout (Week 3-4)
- **10%** → **50%** → **100%** staged release
- **Monitoring**: Crash rates, user reviews, performance metrics
- **Rollback plan**: Ready to halt rollout if issues emerge

## Store Listing Completion

### Required before production:
- [ ] Final app icon (1024x1024)
- [ ] Feature graphic (1024x500) 
- [ ] 5 screenshots captured and uploaded
- [ ] App description finalized
- [ ] Privacy policy URL provided
- [ ] Data safety form completed
- [ ] Content rating questionnaire
- [ ] Pricing set (free/paid decision)

### Current Status:
- [x] Privacy policy ready (docs/PRIVACY.md)
- [x] Data safety responses prepared (DATA_SAFETY_DRAFT.md)
- [x] Store description written (store_listing.md)
- [ ] Final assets needed (icons, graphics, screenshots)

## Compliance Verification

### Play Store Policies ✅
- **Data Collection**: None - fully offline app
- **Target Audience**: 13+ (with parental guidance for younger users)
- **Content Rating**: Educational, no objectionable content
- **Privacy**: No permissions required, no data transmission

### Pre-Launch Requirements
- [ ] Play Console account in good standing
- [ ] Release signing key configured (for production)
- [ ] All store assets uploaded and approved
- [ ] Internal testing completed successfully

## Monitoring & Response Plan

### Key Metrics to Track
- Install success rate
- Crash-free session rate (target: >99.5%)
- User ratings and reviews
- Performance on various device types

### Issue Response Protocol
1. **P0 Issues**: Immediate rollout halt, hotfix within 24h
2. **P1 Issues**: Hotfix within 48-72h, targeted release
3. **P2 Issues**: Include in next planned release

---

**Next Steps**: 
1. Upload AAB to internal testing track
2. Invite internal testers
3. Monitor feedback and metrics
4. Prepare assets for production release