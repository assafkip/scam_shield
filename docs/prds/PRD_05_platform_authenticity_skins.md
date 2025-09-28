# PRD-05: Platform Authenticity Skins

## Goal
Create authentic visual theming system that makes conversations look like real WhatsApp, Gmail, SMS, Tinder, and other platforms without duplicating conversation logic.

## Why Now
Generic chat UI reduces immersion and fails to trigger platform-specific psychological responses. Authentic visual styling increases training effectiveness by simulating real-world contexts where scams occur.

## Scope

### In Scope
- Themeable conversation UI system
- 5 platform skins: WhatsApp, SMS, Gmail, Tinder, Instagram DM
- Metadata-driven skin selection per scenario
- Authentic visual elements (bubbles, fonts, colors, layouts)
- Accessibility compliance across all skins

### Out of Scope
- Platform-specific conversation logic
- Real platform integration or APIs
- Trademark/copyright compliance (educational use disclaimer)
- Platform authentication flows

## UX

### Platform Skin Examples

**WhatsApp Skin:**
```
┌─────────────────────────────────────┐
│ ← John Smith               🎯 ⋮     │
├─────────────────────────────────────┤
│     Hey! I need help with my        │
│     bank account urgently       ✓✓ │
│                                     │
│ I can help you with that            │
│ What's the issue?              ✓   │
└─────────────────────────────────────┘
```

**Email Skin (Gmail):**
```
┌─────────────────────────────────────┐
│ Inbox  ⭐ bank.security@trust.com    │
│ URGENT: Account Security Alert       │
│ ────────────────────────────────────│
│ From: bank.security@trust.com       │
│ To: you@email.com                   │
│ Subject: URGENT: Account Compromised │
│                                     │
│ Dear valued customer...             │
└─────────────────────────────────────┘
```

### Skin Selection (Invisible to User)
```json
{
  "scenarioId": "bank_whatsapp_001",
  "platform": "whatsapp",
  "skinConfig": {
    "contactName": "First National Bank",
    "avatar": "bank_icon.png",
    "timestamp": "auto"
  }
}
```

## Data Model

### Skin Configuration Schema
```json
{
  "platformSkins": {
    "whatsapp": {
      "bubbleStyle": "rounded_corners",
      "fontFamily": "Roboto",
      "primaryColor": "#25D366",
      "backgroundColor": "#ECE5DD",
      "messagePadding": 12,
      "avatarSize": 40
    },
    "sms": {
      "bubbleStyle": "system_native",
      "fontFamily": "San Francisco",
      "primaryColor": "#007AFF",
      "backgroundColor": "#FFFFFF",
      "messagePadding": 8,
      "avatarSize": 0
    }
  }
}
```

### Scenario Skin Metadata
```json
{
  "id": "scenario_001",
  "platformSkin": "whatsapp",
  "skinConfig": {
    "contactName": "Bank Security",
    "contactNumber": "+1 555-BANK",
    "avatar": "assets/avatars/bank.png",
    "verified": false,
    "groupChat": false
  }
}
```

## State & Async

### Skin Manager
```dart
class SkinManager {
  Map<String, PlatformSkin> availableSkins;

  PlatformSkin getSkin(String platformId);
  Widget applySkin(Widget conversation, SkinConfig config);
  bool validateSkinAccessibility(PlatformSkin skin);
}
```

### Platform-Specific Components
```dart
abstract class PlatformSkin {
  Widget buildMessageBubble(Message message, SkinConfig config);
  Widget buildContactHeader(ContactInfo contact);
  Widget buildInputArea();
  Color getBackgroundColor();
  TextStyle getMessageTextStyle();
}
```

### Error Handling
- Skin loading failure → fallback to default skin
- Missing skin assets → use placeholder components
- Invalid skin configuration → log warning, use defaults

## A11y

### Universal Accessibility
- All skins maintain 4.5:1 contrast ratio minimum
- Text size scaling applies to all platform skins
- Focus indicators visible across all themes

### Semantic Consistency
- Platform-agnostic semantic labels
- Message structure announced consistently
- Platform skin doesn't affect screen reader navigation

### High Contrast Mode
- All skins support high contrast override
- Essential information visible without color dependence
- Platform aesthetics degraded gracefully for accessibility

## Test Plan

### Unit Tests
- `SkinManager.getSkin()` returns correct platform skin
- `PlatformSkin.applySkin()` applies styling without breaking layout
- Accessibility validation for all 5 platform skins
- Skin configuration loading and validation

### Visual Tests
- Screenshot comparison tests for each platform skin
- Layout consistency across different message lengths
- Responsive behavior on different screen sizes

### Golden Tests
- **Skin coverage**: All 5 platforms implemented and functional
- **A11y compliance**: Contrast ratios meet WCAG standards
- **Consistency**: Core conversation functionality identical across skins

### A11y Tests
- Screen reader experience identical across platforms
- High contrast mode works with all skins
- Touch targets maintain size requirements

### Performance
- Skin application adds <100ms to conversation loading
- Memory usage increase <20% for themed conversations
- Smooth animations maintained across all skins

## Acceptance Criteria

**GIVEN** a scenario configured with a specific platform skin
**WHEN** the conversation loads
**THEN** the UI authentically resembles the target platform

**GIVEN** platform-specific visual styling
**WHEN** users interact with conversations
**THEN** core functionality remains identical across all skins

**GIVEN** accessibility requirements
**WHEN** any platform skin is applied
**THEN** contrast ratios, text scaling, and screen reader support are maintained

**GIVEN** 5 different platform skins
**WHEN** applied to the same conversation content
**THEN** message content and choices remain functionally identical

## Risks & Mitigations

### Risk: Platform Legal Issues
**Likelihood**: Low | **Impact**: High
**Mitigation**: Educational use disclaimer, avoid trademark infringement, generic naming

### Risk: Accessibility Degradation
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Accessibility testing for every skin, automated contrast checking

### Risk: Maintenance Burden
**Likelihood**: High | **Impact**: Medium
**Mitigation**: Shared base components, automated testing, minimal platform-specific code

## Rollout

### Phase 1: Infrastructure
- Build skin management system
- Create base skin interface
- Feature flag: `platform_skins`

### Phase 2: Implementation
- Implement 2 skins (WhatsApp, SMS) as pilot
- Test with existing scenarios
- Validate accessibility compliance

### Phase 3: Expansion
- Add remaining 3 skins (Gmail, Tinder, Instagram)
- Apply to scenario library
- Performance optimization

## Done When

- [ ] SkinManager system implemented with plugin architecture
- [ ] 5 platform skins created: WhatsApp, SMS, Gmail, Tinder, Instagram DM
- [ ] Metadata-driven skin selection working per scenario
- [ ] All skins maintain identical conversation functionality
- [ ] A11y compliance verified across all platform skins
- [ ] Contrast ratios meet WCAG standards for all themes
- [ ] Visual regression tests prevent skin degradation
- [ ] Performance impact <100ms and <20% memory overhead
- [ ] Educational use disclaimer added for platform resemblance
- [ ] User testing confirms increased immersion and engagement

---

**Dependencies**: PRD-01 (Unified Engine)
**Estimated Effort**: 1.5 weeks
**Owner**: TBD
**Priority**: P2 (UX enhancement)