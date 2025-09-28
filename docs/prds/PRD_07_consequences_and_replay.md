# PRD-07: Consequences & Replay

## Goal
Implement realistic end-of-conversation outcomes (money lost, missed benefits, calibrated success) and "replay from decision point" functionality for key conversation nodes.

## Why Now
Abstract "you failed" messages don't create lasting educational impact. Realistic consequences help users understand real-world stakes, while replay functionality enables learning from mistakes without restarting entire scenarios.

## Scope

### In Scope
- Three consequence types: financial loss, missed opportunity, calibrated success
- Realistic outcome descriptions with specific dollar amounts/impacts
- Replay functionality from key decision points
- State preservation and restoration for replay points
- Consequence variation based on user choices

### Out of Scope
- Real financial transactions or accounts
- Cross-scenario consequence tracking
- Multiplayer consequences
- Advanced replay analytics

## UX

### Consequence Examples

**Financial Loss:**
```
┌─────────────────────────────────────┐
│ 💸 CONSEQUENCE: MONEY LOST          │
│                                     │
│ You shared your bank login details  │
│ Estimated loss: $2,400             │
│                                     │
│ • Drained checking account          │
│ • Overdraft fees                    │
│ • Identity theft risk               │
│                                     │
│ [Learn More] [Replay Decision]      │
└─────────────────────────────────────┘
```

**Missed Opportunity:**
```
┌─────────────────────────────────────┐
│ ⚠️  MISSED LEGITIMATE OPPORTUNITY    │
│                                     │
│ This was a real bank security alert │
│ By ignoring it, you missed:         │
│                                     │
│ • Preventing actual fraud           │
│ • $500 in unauthorized charges      │
│ • Credit score protection           │
│                                     │
│ [Understand Why] [Replay]           │
└─────────────────────────────────────┘
```

**Calibrated Success:**
```
┌─────────────────────────────────────┐
│ ✅ EXCELLENT SCAM DETECTION         │
│                                     │
│ You correctly identified the scam   │
│ and protected yourself from:        │
│                                     │
│ • $1,200 in potential losses       │
│ • Identity theft                    │
│ • Ongoing harassment                │
│                                     │
│ [Next Challenge] [Review Tactics]   │
└─────────────────────────────────────┘
```

### Replay Interface
```
┌─────────────────────────────────────┐
│ 🔄 REPLAY FROM DECISION POINT       │
│                                     │
│ Go back to: "Bank asks for login"   │
│ You previously chose: "Share info"  │
│                                     │
│ [Replay from Here] [Full Restart]   │
└─────────────────────────────────────┘
```

## Data Model

### Consequence Configuration
```json
{
  "consequences": {
    "financial_loss": {
      "type": "money_lost",
      "amount": 2400,
      "description": "Drained checking account + fees",
      "breakdown": [
        "Checking account: $1,900",
        "Overdraft fees: $350",
        "Recovery costs: $150"
      ],
      "recovery_steps": [
        "Contact bank immediately",
        "File fraud report",
        "Monitor credit reports"
      ]
    },
    "missed_opportunity": {
      "type": "legitimate_ignored",
      "missed_benefit": "Fraud prevention",
      "cost_of_ignoring": 500,
      "explanation": "Real security alert would have prevented unauthorized charges"
    },
    "calibrated_success": {
      "type": "correct_detection",
      "protected_amount": 1200,
      "skills_demonstrated": [
        "Recognized urgency pressure",
        "Verified sender identity",
        "Avoided information sharing"
      ]
    }
  }
}
```

### Replay Points Schema
```json
{
  "replayPoints": [
    {
      "id": "critical_decision_001",
      "stepId": "bank_login_request",
      "description": "Bank asks for login details",
      "stateSnapshot": {
        "conversationHistory": [...],
        "userChoices": {...},
        "pressureLevel": 45,
        "trustLevel": 67
      },
      "isKeyDecision": true
    }
  ]
}
```

## State & Async

### Consequence Calculator
```dart
class ConsequenceCalculator {
  ConsequenceResult calculateOutcome(
    List<UserChoice> choices,
    ScenarioOutcome outcome
  );

  double estimateFinancialImpact(UserChoice criticalChoice);
  List<String> getRecoverySteps(ConsequenceType type);
}
```

### Replay System
```dart
class ReplayManager {
  Map<String, ConversationSnapshot> replayPoints;

  void saveReplayPoint(String pointId, ConversationState state);
  ConversationState restoreFromReplayPoint(String pointId);
  List<ReplayPoint> getAvailableReplayPoints();
}
```

### Error Handling
- Consequence calculation failure → show generic outcome
- Replay point corruption → offer full restart option
- State restoration failure → log error, continue from current state

## A11y

### Semantic Labels
- Consequences: "Consequence outcome: {type}, impact: {description}"
- Financial amounts: "Estimated financial loss: {amount} dollars"
- Replay options: "Replay conversation from {decision_point_description}"

### Visual Support
- Consequence icons with text descriptions (not color-only)
- High contrast support for outcome displays
- Clear focus indicators on replay buttons

### Screen Reader
- Full consequence details read aloud
- Replay point descriptions announced
- Navigation between consequence details and replay options

## Test Plan

### Unit Tests
- `ConsequenceCalculator.calculateOutcome()` with various choice patterns
- `ReplayManager.saveReplayPoint()` state preservation accuracy
- Financial impact calculations for different scenario types
- Replay point restoration and state consistency

### Flow Tests
- Complete scenario to each consequence type
- Replay from different decision points with state accuracy
- Consequence variation based on different user choice patterns

### Golden Tests
- **Consequence accuracy**: Outcomes match choice patterns appropriately
- **Replay functionality**: State restoration maintains conversation consistency
- **Educational value**: Consequences provide actionable learning insights

### A11y Tests
- Screen reader access to consequence details
- High contrast mode compatibility
- Keyboard navigation through replay options

### Performance
- Consequence calculation <200ms
- Replay state restoration <300ms
- State snapshot saving <100ms

## Acceptance Criteria

**GIVEN** a user completes a scenario with risky choices
**WHEN** they reach the consequence phase
**THEN** realistic financial loss with specific amounts and breakdown is shown

**GIVEN** a user incorrectly rejects a legitimate message
**WHEN** consequences are calculated
**THEN** missed opportunity outcome shows real-world impact of over-caution

**GIVEN** replay points are available in a conversation
**WHEN** user selects replay from decision point
**THEN** conversation state is accurately restored to that moment

**GIVEN** different types of consequences across scenarios
**WHEN** reviewing educational effectiveness
**THEN** all three consequence types (loss, missed opportunity, success) appear appropriately

## Risks & Mitigations

### Risk: Overly Dramatic Consequences
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Research-based impact amounts, expert review of consequence realism

### Risk: Replay State Complexity
**Likelihood**: High | **Impact**: Medium
**Mitigation**: Simple state snapshots initially, extensive testing of restoration

### Risk: User Discouragement from Negative Outcomes
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Balanced consequences, clear learning focus, replay encouragement

## Rollout

### Phase 1: Consequence System
- Implement three consequence types
- Add outcome calculation logic
- Feature flag: `realistic_consequences`

### Phase 2: Replay Functionality
- Build replay point saving and restoration
- Add replay UI components
- Test state preservation accuracy

### Phase 3: Integration & Tuning
- Apply to scenario library
- Tune consequence amounts based on feedback
- Optimize replay performance

## Done When

- [ ] Three consequence types implemented: financial loss, missed opportunity, calibrated success
- [ ] Realistic outcome descriptions with specific dollar amounts and impacts
- [ ] Replay functionality from key decision points preserves conversation state
- [ ] Consequence variation based on user choice patterns
- [ ] Recovery guidance provided for negative outcomes
- [ ] A11y support for consequence details and replay options
- [ ] Performance benchmarks met for calculation and replay
- [ ] User testing confirms educational value of consequences
- [ ] Golden tests verify consequence accuracy and replay state preservation
- [ ] Expert review validates consequence realism and educational effectiveness

---

**Dependencies**: PRD-01 (Unified Engine), PRD-02 (Trust Calculation)
**Estimated Effort**: 1.5 weeks
**Owner**: TBD
**Priority**: P1 (Core educational feature)