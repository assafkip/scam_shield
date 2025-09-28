# PRD-02: Trust-from-Choices & Pressure Meter

## Goal
Replace explicit trust sliders with implicit trust calculation from user choices, and add a live pressure meter that responds to manipulative tactics during conversation flow.

## Why Now
The audit found explicit trust sliders create artificial UX friction. Real-world trust decisions are intuitive and contextual. By inferring trust from choice semantics and showing pressure escalation, we create more realistic psychological simulation that matches how scam psychology actually works.

## Scope

### In Scope
- Remove explicit trust slider UI components
- Implement choice-based trust inference engine
- Add live pressure meter widget
- Trust calculation from choice safety ratings
- Pressure visualization responding to tactic detection
- Trust summary in end-of-conversation debrief

### Out of Scope
- Advanced pressure algorithms (PRD-03)
- Historical trust tracking across scenarios
- Multiplayer trust comparisons
- Trust-based adaptive difficulty (PRD-03)

## UX

### Pressure Meter Design
```
┌─────────────────────────────────────┐
│ PRESSURE LEVEL                      │
│ ████████░░░░░░░░░░░░ 40%            │
│ Low ←────────────────→ High         │
└─────────────────────────────────────┘
```

### Pressure States
- **0-25%**: Green bar, "Low Pressure"
- **26-50%**: Yellow bar, "Moderate Pressure"
- **51-75%**: Orange bar, "High Pressure"
- **76-100%**: Red bar, "Extreme Pressure"

### Trust Summary UI
```
┌─────────────────────────────────────┐
│ FINAL TRUST ASSESSMENT              │
│                                     │
│ Your Trust Level: 73%               │
│ Optimal Range: 15-25%               │
│                                     │
│ Result: ⚠️ Over-trusting            │
│ This was a SCAM attempt             │
└─────────────────────────────────────┘
```

### Copy/Labels
- Pressure meter: "Psychological Pressure"
- Pressure states: "Low/Moderate/High/Extreme Pressure"
- Trust summary: "Your trust level was calculated from your choices"
- Debrief header: "Trust Assessment Results"

## Data Model

### Choice Enhancement
```json
{
  "id": "string",
  "text": "string",
  "nextStepId": "string",
  "isSafe": boolean,
  "trustDelta": number,     // -20 to +20
  "pressureDelta": number,  // 0 to +15
  "tacticsUsed": ["authority", "urgency", "social_proof"]
}
```

### Pressure Calculation Schema
```json
{
  "tacticWeights": {
    "authority": 8,
    "urgency": 12,
    "social_proof": 6,
    "emotion": 10,
    "foot_in_door": 4,
    "norm_activation": 7
  },
  "pressureDecay": 0.95,
  "maxPressure": 100
}
```

### Trust Calculation Rules
```json
{
  "baselineTrust": 50,
  "choiceModifiers": {
    "safe_choice": -5,
    "risky_choice": +8,
    "very_risky": +15
  },
  "contextModifiers": {
    "urgent_deadline": +5,
    "authority_sender": +3,
    "personal_info_request": +7
  }
}
```

## State & Async

### PressureState Management
```dart
class PressureState {
  double currentPressure;
  Map<String, int> activeTactics;
  List<PressureEvent> history;

  void addTactic(String tactic, int weight);
  void decay();
  double calculateLevel();
}
```

### Trust Calculation
```dart
class TrustCalculator {
  double calculate(List<Choice> choices, ScenarioContext context);
  TrustResult generateSummary(double trustLevel, Scenario scenario);
}
```

### Error Handling
- Invalid trust delta → clamp to valid range (-20, +20)
- Missing tactic weights → use default values
- Pressure calculation overflow → cap at 100%

## A11y

### Semantic Labels
- Pressure meter: "Psychological pressure level: {percentage}%, {state}"
- Trust result: "Your final trust level: {percentage}%"
- Comparison: "Optimal trust for this scenario: {range}%"

### Visual Accessibility
- Pressure meter uses color + text labels (not color-only)
- High contrast mode compatible
- Large text affects pressure meter font size

### Screen Reader
- Pressure changes announced: "Pressure increasing to moderate level"
- Trust calculation explained: "Based on your choices, trust calculated at {percentage}%"

## Test Plan

### Unit Tests
- `TrustCalculator.calculate()` with various choice combinations
- `PressureState.addTactic()` with different tactic weights
- Trust delta clamping with extreme values
- Pressure decay over time simulation

### Flow Tests
- Complete conversation with pressure escalation
- Trust calculation accuracy across scenario types
- Pressure meter visual updates on choice selection

### Golden Tests
- **Trust accuracy**: Calculate trust for known choice patterns
- **Pressure sensitivity**: Verify pressure responds to tactic detection
- **Boundary testing**: Edge cases at 0% and 100% pressure

### A11y Tests
- Screen reader announces pressure changes
- High contrast mode doesn't break meter visibility
- Large text scaling maintains meter readability

### Performance
- Trust calculation <50ms per choice
- Pressure meter animation smooth at 60fps
- No memory leaks in pressure history

## Acceptance Criteria

**GIVEN** a user makes risky choices in a conversation
**WHEN** choices contain manipulative tactics
**THEN** pressure meter visibly escalates and trust increases appropriately

**GIVEN** a user completes a scam scenario
**WHEN** they view the trust summary
**THEN** trust level reflects their choice pattern and shows comparison to optimal range

**GIVEN** pressure-inducing tactics are present
**WHEN** multiple tactics accumulate during conversation
**THEN** pressure meter shows appropriate escalation with correct visual state

**GIVEN** accessibility requirements
**WHEN** using screen reader or high contrast mode
**THEN** pressure and trust information is accessible without visual indicators

## Risks & Mitigations

### Risk: Trust Calculation Accuracy
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Extensive testing with known scenarios, expert validation of psychology

### Risk: Pressure Sensitivity Tuning
**Likelihood**: High | **Impact**: Medium
**Mitigation**: A/B testing with different tactic weights, user feedback collection

### Risk: UX Confusion Without Explicit Trust
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Clear explanation in debrief, tutorial scenario explaining system

## Rollout

### Phase 1: Implementation
- Build trust calculator and pressure meter components
- Feature flag: `implicit_trust_system`
- Test with 2 scenarios from PRD-01

### Phase 2: Calibration
- Tune tactic weights based on user behavior
- Adjust pressure sensitivity
- Validate trust calculation accuracy

### Phase 3: Expansion
- Apply to additional scenarios
- Monitor user engagement metrics
- Collect qualitative feedback

## Done When

- [ ] Explicit trust sliders removed from all conversation UIs
- [ ] TrustCalculator class implemented with choice-based inference
- [ ] PressureMeter widget implemented with real-time updates
- [ ] Trust summary in conversation debrief shows calculated trust vs optimal
- [ ] Pressure meter responds to tactic detection in 2 pilot scenarios
- [ ] A11y labels for pressure and trust components
- [ ] Unit tests cover trust calculation edge cases
- [ ] Performance benchmarks met (<50ms calculations)
- [ ] User testing validates intuitive understanding
- [ ] Golden tests verify pressure escalation on risky paths

---

**Dependencies**: PRD-01 (Unified Conversation Engine)
**Estimated Effort**: 1.5 weeks
**Owner**: TBD
**Priority**: P1 (Core UX improvement)