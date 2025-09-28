# PRD-04: Scenario Depth Upgrade (First 5)

## Goal
Expand 5 priority scenarios from current shallow interactions to 8-15 message depth with true branching paths and ambiguous cases that challenge trust calibration.

## Why Now
The audit revealed many scenarios lack depth and branching complexity needed for effective training. Shallow scenarios don't simulate real-world scam psychology where attackers gradually build trust and apply pressure over extended conversations.

## Scope

### In Scope
- Expand 5 existing scenarios to 8-15 messages minimum
- Add branching conversation paths with meaningful consequences
- Include ambiguous legitimate and scam cases
- Implement gradual trust-building and pressure escalation
- Add context preservation across conversation threads

### Out of Scope
- Creating entirely new scenarios
- Visual theming (PRD-05)
- Adaptive difficulty routing (handled by PRD-03)
- Automated scenario generation

## UX

### Extended Conversation Flow
```
Opening (1-2 messages)
   ↓
Trust Building (3-5 messages)
   ↓ ↙ ↘
Branch A    Branch B    Branch C
↓           ↓           ↓
Escalation  Middle      De-escalation
   ↓ ↙ ↘       ↓           ↓
Resolution paths      Ambiguous case
```

### Ambiguous Case Indicators
```
┌─────────────────────────────────────┐
│ ⚠️  AMBIGUOUS SCENARIO              │
│ This could be legitimate OR a scam  │
│ Pay attention to subtle details     │
└─────────────────────────────────────┘
```

### Progress Through Deep Conversation
```
Message Thread (scrollable)
├── Message 1-3: Opening
├── Message 4-7: Trust building
├── Message 8-10: Pressure tactics
├── Message 11-13: Escalation
└── Message 14-15: Resolution/choice
```

### Copy/Labels
- Ambiguous warning: "This could be legitimate OR a scam"
- Progress depth: "Deep conversation: message {X} of {Y}"
- Context reminder: "Remember: {previous_context}"

## Data Model

### Enhanced Scenario Structure
```json
{
  "id": "scenario_deep_001",
  "title": "Extended Bank Security Alert",
  "depth": 12,
  "complexity": "high",
  "hasAmbiguity": true,
  "conversationPhases": [
    {
      "phase": "opening",
      "messages": [1, 2]
    },
    {
      "phase": "trust_building",
      "messages": [3, 4, 5, 6]
    },
    {
      "phase": "pressure_escalation",
      "messages": [7, 8, 9, 10]
    },
    {
      "phase": "critical_decision",
      "messages": [11, 12]
    }
  ],
  "branchingPoints": [
    {
      "atMessageId": "msg_005",
      "branches": ["suspicious_path", "trusting_path"]
    },
    {
      "atMessageId": "msg_009",
      "branches": ["verify_path", "comply_path", "ignore_path"]
    }
  ],
  "ambiguousCases": [
    {
      "type": "legitimate_with_red_flags",
      "description": "Real bank with poor communication",
      "confusion_factor": "urgent_language"
    }
  ]
}
```

### Message Thread Context
```json
{
  "contextTracking": {
    "priorClaims": ["account_compromise", "immediate_action"],
    "establishedFacts": ["caller_knew_partial_info"],
    "inconsistencies": ["domain_mismatch", "grammar_errors"],
    "pressureTactics": ["time_limit", "consequence_threat"]
  }
}
```

## State & Async

### Deep Conversation State
```dart
class DeepConversationState {
  List<ConversationPhase> phases;
  Map<String, dynamic> accumulatedContext;
  List<String> activeBranches;
  Set<String> detectedInconsistencies;

  void updateContext(String key, dynamic value);
  bool shouldShowAmbiguityWarning();
  ConversationPhase getCurrentPhase();
}
```

### Context Preservation
```dart
class ContextTracker {
  Map<String, List<String>> priorClaims;
  Set<String> establishedFacts;
  List<String> detectedRedFlags;

  void addClaim(String speaker, String claim);
  List<String> getInconsistencies();
  String getContextSummary();
}
```

### Error Handling
- Deep conversation state corruption → checkpoint restoration
- Branch navigation failure → fallback to main path
- Context overflow → summarize and compress oldest entries

## A11y

### Semantic Labels
- Deep conversation: "Extended conversation, message {X} of {Y}"
- Phase indicator: "Conversation phase: {phase_name}"
- Ambiguity warning: "Ambiguous scenario warning: this could be legitimate or fraudulent"
- Context reminder: "Context from earlier: {summary}"

### Navigation Support
- Skip to phase options for screen readers
- Context summary available on demand
- Previous message review navigation

### Visual Support
- Phase progress indicators with text labels
- High contrast compatible ambiguity warnings
- Scroll position preservation

## Test Plan

### Unit Tests
- Deep conversation state management across 15+ messages
- Context tracking accuracy with multiple claims and facts
- Branch navigation with state preservation
- Ambiguous case detection and warning triggers

### Flow Tests
- Complete 8-15 message conversations without state loss
- Branch selection preserves context appropriately
- Ambiguous scenarios present appropriate warnings
- Phase transitions work correctly

### Golden Tests
- **Depth verification**: All 5 scenarios reach minimum 8 messages
- **Branching complexity**: Each scenario has ≥2 meaningful branch points
- **Ambiguity presence**: At least 1 ambiguous legitimate, 1 ambiguous scam per scenario
- **Tactic progression**: Pressure tactics escalate through conversation phases

### A11y Tests
- Screen reader can navigate through deep conversations
- Context summaries are accessible
- Ambiguity warnings properly announced

### Performance
- Deep conversation loading <300ms
- Context tracking adds <50ms per message
- Smooth scrolling through 15+ message threads

## Acceptance Criteria

**GIVEN** the 5 priority scenarios
**WHEN** I expand them with depth and branching
**THEN** each reaches 8-15 messages with meaningful conversation progression

**GIVEN** a deep conversation in progress
**WHEN** I make choices at branching points
**THEN** context is preserved and inconsistencies are tracked across branches

**GIVEN** scenarios with ambiguous cases
**WHEN** users encounter legitimate-seeming scams or suspicious-seeming legitimate messages
**THEN** appropriate warnings appear and users can distinguish through careful analysis

**GIVEN** extended conversation phases
**WHEN** pressure tactics escalate through trust-building to critical decisions
**THEN** psychological progression matches real-world scam patterns

## Risks & Mitigations

### Risk: Scenario Writing Complexity
**Likelihood**: High | **Impact**: Medium
**Mitigation**: Start with existing scenarios, incremental expansion, expert review

### Risk: User Fatigue with Long Conversations
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Progress indicators, save/resume functionality, engaging content

### Risk: Context Tracking Complexity
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Simple context model initially, extensive testing of state preservation

## Rollout

### Phase 1: Scenario Selection
- Choose 5 scenarios representing different scam types
- Analyze current depth and identify expansion points
- Feature flag: `deep_scenarios_pilot`

### Phase 2: Expansion Implementation
- Extend scenarios to target depth 8-15 messages
- Add branching points and ambiguous cases
- Implement context tracking

### Phase 3: Validation
- User testing for engagement and fatigue
- Verify educational effectiveness
- Performance optimization

## Done When

- [ ] 5 priority scenarios expanded to 8-15 message depth
- [ ] Each scenario has ≥2 meaningful branching points
- [ ] Ambiguous cases implemented (1 ambiguous legit, 1 ambiguous scam minimum per scenario)
- [ ] Context tracking preserves conversation state across branches
- [ ] Phase progression from trust-building to pressure escalation
- [ ] A11y support for deep conversation navigation
- [ ] Golden tests verify depth ≥8, branching ≥2, ambiguity presence
- [ ] Performance benchmarks met for deep conversations
- [ ] User testing confirms engagement without fatigue
- [ ] Expert review validates psychological accuracy

---

**Dependencies**: PRD-01 (Unified Engine)
**Estimated Effort**: 2 weeks
**Owner**: TBD
**Priority**: P1 (Content quality foundation)