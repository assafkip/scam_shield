# PRD-09: Recovery Training

## Goal
Implement post-scam recovery training with damage control guidance, offline checklists, and actionable steps for users who have been compromised.

## Why Now
Current training focuses only on prevention. Users who fall for scams need immediate, practical guidance for damage control. Recovery training provides value even after prevention fails and builds confidence for future protection.

## Scope

### In Scope
- Automatic recovery flow triggered by scam outcomes
- Damage control checklists for different scam types
- Offline-accessible recovery resources
- Step-by-step action guides with timelines
- Emotional support and reassurance messaging

### Out of Scope
- Real-world victim support services integration
- Legal advice or financial counseling
- Reporting to law enforcement (guidance only)
- Identity monitoring services

## UX

### Recovery Flow Trigger
```
[Scam Outcome Detected]
        ↓
┌─────────────────────────────────────┐
│ 🆘 IMMEDIATE ACTION NEEDED          │
│                                     │
│ You shared sensitive information    │
│ Let's minimize the damage right now │
│                                     │
│ [Start Recovery Guide] [Later]      │
└─────────────────────────────────────┘
```

### Recovery Checklist Interface
```
┌─────────────────────────────────────┐
│ 🔒 ACCOUNT SECURITY RECOVERY        │
│                                     │
│ ✅ Change banking passwords         │
│ ✅ Contact bank fraud department    │
│ ⏳ Monitor account activity         │
│ ⭕ File police report               │
│ ⭕ Contact credit bureaus           │
│                                     │
│ Next: Monitor for 30 days           │
│ [Mark Complete] [Get Help]          │
└─────────────────────────────────────┘
```

### Timeline-Based Actions
```
┌─────────────────────────────────────┐
│ ⏰ RECOVERY TIMELINE                │
│                                     │
│ IMMEDIATELY (next 15 minutes):     │
│ • Change all passwords              │
│ • Contact bank/credit cards        │
│                                     │
│ TODAY (next 24 hours):             │
│ • File fraud reports               │
│ • Enable account alerts            │
│                                     │
│ THIS WEEK:                         │
│ • Monitor statements daily         │
│ • Review credit reports            │
└─────────────────────────────────────┘
```

## Data Model

### Recovery Guide Schema
```json
{
  "recoveryGuides": {
    "financial_scam": {
      "triggerConditions": ["shared_banking_info", "money_sent"],
      "urgency": "immediate",
      "steps": [
        {
          "id": "secure_accounts",
          "title": "Secure Your Accounts",
          "timeline": "immediate",
          "actions": [
            "Change online banking password",
            "Enable two-factor authentication",
            "Contact bank fraud department: 1-800-XXX-XXXX"
          ],
          "estimated_time": "15 minutes"
        },
        {
          "id": "stop_payments",
          "title": "Stop Ongoing Payments",
          "timeline": "within_1_hour",
          "actions": [
            "Cancel any pending transfers",
            "Stop payment on recent checks",
            "Freeze debit/credit cards"
          ]
        }
      ]
    },
    "identity_theft": {
      "triggerConditions": ["shared_ssn", "shared_personal_info"],
      "steps": [
        {
          "id": "credit_freeze",
          "title": "Freeze Your Credit",
          "actions": [
            "Contact Experian: freeze online",
            "Contact Equifax: freeze online",
            "Contact TransUnion: freeze online"
          ]
        }
      ]
    }
  }
}
```

### Progress Tracking
```json
{
  "recoveryProgress": {
    "scamType": "financial_scam",
    "startedAt": "2025-09-21T14:30:00Z",
    "completedSteps": ["secure_accounts"],
    "pendingSteps": ["stop_payments", "file_reports"],
    "reminderSchedule": {
      "daily_monitoring": 30,
      "credit_check": 90
    }
  }
}
```

## State & Async

### Recovery Manager
```dart
class RecoveryManager {
  RecoveryGuide getGuideForScamType(ScamType type);
  void triggerRecoveryFlow(ScamOutcome outcome);
  List<RecoveryStep> getTimelineSteps(Duration timeSinceScam);
}
```

### Progress Tracker
```dart
class RecoveryProgressTracker {
  Map<String, bool> completedSteps;
  DateTime scamDate;

  void markStepComplete(String stepId);
  List<RecoveryStep> getOverdueSteps();
  bool isRecoveryComplete();
}
```

### Error Handling
- Recovery guide loading failure → show generic emergency contacts
- Progress tracking failure → continue with guidance, log issue
- Offline access required → all content cached locally

## A11y

### Semantic Labels
- Recovery urgency: "Immediate action required for scam recovery"
- Step status: "Recovery step: {title}, status: {completed/pending}"
- Timeline: "Action needed within {timeframe}: {action}"

### Visual Priority
- High contrast for urgent steps
- Clear visual hierarchy for timeline priorities
- Icons + text for step completion status

### Screen Reader
- Recovery flow announces urgency level
- Progress through checklist clearly communicated
- Timeline information accessible without visual layout

## Test Plan

### Unit Tests
- `RecoveryManager.getGuideForScamType()` returns appropriate guides
- `RecoveryProgressTracker.markStepComplete()` updates state correctly
- Recovery trigger conditions match scam outcomes accurately
- Timeline calculation for recovery steps

### Flow Tests
- Complete recovery flow from scam outcome to completion
- Progress tracking through multi-day recovery timeline
- Offline access to recovery guides and checklists
- Recovery restart after interruption

### Golden Tests
- **Coverage**: Recovery guides exist for all major scam outcome types
- **Actionability**: All recovery steps include specific, actionable instructions
- **Timeline accuracy**: Recovery timelines match real-world urgency needs

### A11y Tests
- Screen reader access to urgent recovery information
- High contrast mode for critical action items
- Keyboard navigation through recovery checklists

### Performance
- Recovery guide loading <100ms (locally cached)
- Progress updates save immediately
- Offline access works without network

## Acceptance Criteria

**GIVEN** a user falls for a financial scam in training
**WHEN** the scam outcome is detected
**THEN** recovery flow automatically triggers with appropriate damage control guide

**GIVEN** recovery steps with different timelines
**WHEN** user accesses recovery guidance
**THEN** immediate, daily, and weekly actions are clearly differentiated

**GIVEN** offline access requirements
**WHEN** recovery guides are needed without internet
**THEN** all essential recovery information is available locally

**GIVEN** multi-day recovery process
**WHEN** user returns to recovery guidance
**THEN** progress is preserved and next steps are clearly indicated

## Risks & Mitigations

### Risk: Providing Inadequate Recovery Advice
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Expert review by fraud prevention specialists, disclaimer about professional advice

### Risk: User Panic Response
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Calm, reassuring tone, clear step-by-step guidance, emphasis on control

### Risk: Information Quickly Outdated
**Likelihood**: High | **Impact**: Medium
**Mitigation**: Regular content review, focus on general principles vs specific numbers

## Rollout

### Phase 1: Core Recovery Guides
- Implement recovery guides for 3 major scam types
- Build automatic triggering system
- Feature flag: `recovery_training`

### Phase 2: Enhanced Features
- Add progress tracking and timeline management
- Implement offline caching
- Test with user scenarios

### Phase 3: Comprehensive Coverage
- Expand to all scam types in scenario library
- Add emotional support messaging
- Expert review and validation

## Done When

- [ ] Recovery training automatically triggers on scam outcomes
- [ ] Damage control checklists for major scam types (financial, identity, romance)
- [ ] Offline-accessible recovery resources cached locally
- [ ] Timeline-based action guides with immediate/daily/weekly steps
- [ ] Progress tracking through multi-day recovery process
- [ ] Reassuring, action-oriented messaging reduces panic
- [ ] A11y support for urgent recovery information
- [ ] Expert review validates recovery guidance accuracy
- [ ] User testing confirms clarity and actionability of guidance
- [ ] Performance ensures immediate access to critical information

---

**Dependencies**: PRD-01 (Unified Engine), PRD-07 (Consequences)
**Estimated Effort**: 1.5 weeks
**Owner**: TBD
**Priority**: P2 (Post-incident support)