# PRD-01: Unified Conversation Engine v1

## Goal
Consolidate three competing conversation systems into one unified engine that handles all scenario types through a single data model and renderer.

## Why Now
The audit revealed critical architectural fragmentation: three separate conversation engines (`interactive_chat.dart`, `interactive_research_scenario.dart`, `dynamic_interactive_chat.dart`) create maintenance burden, prevent feature sharing, and block unified UX improvements. This foundational work enables all subsequent PRDs.

## Scope

### In Scope
- Unified `ConversationEngine` class handling all conversation types
- Single JSON schema for all scenarios with backward compatibility
- Migration adapter for existing scenarios
- Consolidated conversation renderer component
- Two pilot scenarios running end-to-end on unified engine

### Out of Scope
- Trust inference mechanisms (PRD-02)
- New conversation features (PRD-03+)
- Visual theming/skins (PRD-05)
- Migrating all scenarios (gradual rollout)

## UX

### Unified Conversation Flow
```
[Conversation Header] → scenario.title, context
[Message Thread]     → messages[] with sender avatars
[Choice Buttons]     → choices[] with safety indicators
[Progress Indicator] → step X of Y
[Exit Button]        → "Leave Conversation"
```

### Component Hierarchy
```
UnifiedConversationPage
├── ConversationHeader(scenario.title, scenario.context)
├── MessageThread(messages[], currentStep)
├── ChoicePanel(choices[], onChoiceSelected)
└── ConversationFooter(progress, exitButton)
```

### Copy/Labels
- Header: scenario.title
- Context: scenario.context (shown in italics)
- Exit button: "Leave Training"
- Progress: "Step {current} of {total}"
- Loading: "Loading conversation..."

## Data Model

### Unified Schema
```json
{
  "id": "string",
  "title": "string",
  "context": "string",
  "platform": "whatsapp|sms|email|dating|social",
  "difficulty": 1-3,
  "isScam": boolean,
  "steps": [
    {
      "id": "string",
      "type": "message|choice|end",
      "sender": "string",
      "text": "string",
      "choices": [
        {
          "id": "string",
          "text": "string",
          "nextStepId": "string",
          "isSafe": boolean,
          "tacticsUsed": ["authority", "urgency", "emotion"]
        }
      ],
      "meta": {
        "pressureDelta": number,
        "trustHint": "string",
        "isEnd": boolean
      }
    }
  ],
  "quiz": {
    "questions": [],
    "correctAnswers": []
  },
  "victimStory": "string",
  "optimalTrust": number
}
```

### Migration Map
```json
{
  "legacy": {
    "messages": "→ steps[].text",
    "choices": "→ steps[].choices[]"
  },
  "research": {
    "conversation": "→ steps[]",
    "isEnd": "→ meta.isEnd"
  },
  "dynamic": {
    "enhancedResponses": "→ steps[].meta"
  }
}
```

## State & Async

### State Management
```dart
class ConversationState {
  String scenarioId;
  String currentStepId;
  List<String> visitedSteps;
  Map<String, dynamic> userChoices;
  double calculatedTrust;
  bool isCompleted;
}
```

### Error Handling
- Invalid step transitions → fallback to previous step
- Missing scenario → show error dialog, return to menu
- Malformed JSON → log error, skip malformed step
- Choice timeout → auto-advance with neutral choice

### Guards
- Prevent duplicate choice selection
- Validate step existence before navigation
- Ensure conversation completion tracking

## A11y

### Semantic Labels
- Messages: "Message from {sender}: {text}"
- Choices: "Response option: {text}, Safety: {safe/risky}"
- Progress: "Conversation progress: step {X} of {Y}"
- Exit: "Exit conversation training"

### Large Text Support
- Minimum 16sp for message text
- 14sp for choice buttons
- 18sp for headers

### Contrast
- Message bubbles: 4.5:1 contrast minimum
- Choice buttons: 3:1 contrast for interactive elements
- Safety indicators: Color + icon (not color-only)

## Test Plan

### Unit Tests
- `ConversationEngine.loadScenario()` with all three legacy formats
- `ConversationState.advanceStep()` with valid/invalid transitions
- Migration adapter with sample legacy scenarios
- Error handling for malformed JSON

### Flow Tests
- Complete conversation flow for 2 pilot scenarios
- Choice selection and state transitions
- Conversation completion and results

### Golden Tests
- **Depth check**: Pilot scenarios must have ≥8 steps
- **Branching check**: At least 2 choice branches per scenario
- **Tactic labels**: All choices tagged with relevant tactics

### A11y Tests
- Screen reader announces message content
- Choice buttons have proper focus order
- Large text scaling doesn't break layout

### Performance
- Conversation loading <200ms
- Step transitions <100ms
- No animation jank (60fps maintained)

## Acceptance Criteria

**GIVEN** the legacy three-engine system exists
**WHEN** I implement the unified conversation engine
**THEN** two existing scenarios run end-to-end without functional regression

**GIVEN** a scenario in any legacy format
**WHEN** I load it through the migration adapter
**THEN** it renders correctly in the unified conversation UI

**GIVEN** a unified conversation in progress
**WHEN** I make choices and advance through steps
**THEN** state transitions work correctly and progress is tracked

**GIVEN** golden test requirements
**WHEN** I run tests on pilot scenarios
**THEN** depth ≥8 and branching ≥2 assertions pass

## Risks & Mitigations

### Risk: Schema Migration Complexity
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Incremental migration with adapter pattern, extensive testing

### Risk: UX Regression
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Feature parity checklist, user testing with existing flows

### Risk: Performance Degradation
**Likelihood**: Low | **Impact**: Medium
**Mitigation**: Performance benchmarking, lazy loading for large scenarios

## Rollout

### Phase 1: Infrastructure
- Implement unified engine and data models
- Create migration adapters
- Build test harness

### Phase 2: Pilot
- Convert 2 existing scenarios to unified format
- Feature flag: `unified_conversation_pilot`
- A/B test with 10% of scenarios

### Phase 3: Validation
- Run golden tests
- Performance validation
- UX validation with existing users

## Done When

- [ ] UnifiedConversationEngine class implemented
- [ ] Single JSON schema defined and documented
- [ ] Migration adapters for all three legacy formats
- [ ] Two pilot scenarios running end-to-end
- [ ] Golden tests passing (depth ≥8, branching ≥2)
- [ ] A11y semantic labels added
- [ ] Unit test coverage >90%
- [ ] Performance benchmarks within targets
- [ ] Code review approved
- [ ] Feature flag configured for gradual rollout

---

**Dependencies**: None (foundational work)
**Estimated Effort**: 2 weeks
**Owner**: TBD
**Priority**: P0 (blocks all other PRDs)