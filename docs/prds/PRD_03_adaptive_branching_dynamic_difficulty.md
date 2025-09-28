# PRD-03: Adaptive Branching & Dynamic Difficulty

## Goal
Implement performance-based conversation routing that dynamically adjusts scenario difficulty based on recent user performance, creating personalized challenge levels.

## Why Now
Static scenarios provide uniform difficulty regardless of user skill level. Adaptive branching creates engaging experiences that challenge advanced users while supporting struggling learners, maximizing educational effectiveness for all skill levels.

## Scope

### In Scope
- Performance tracking system across recent scenarios
- Dynamic difficulty calculation algorithm
- Adaptive conversation routing based on performance
- Harder/easier branch variants for existing scenarios
- Recovery path routing after consecutive failures
- Performance-based next step selection

### Out of Scope
- Long-term skill profiling (beyond recent 5 scenarios)
- Cross-user difficulty comparisons
- Manual difficulty selection override
- Completely new scenarios (using existing scenario variants)

## UX

### Adaptive Routing (Invisible to User)
```
User Performance → Algorithm → Route Selection
Recent 2 perfect  → Harder branch
Recent 2 failures → Easier branch
Mixed performance → Standard branch
```

### Performance Feedback (Subtle)
```
┌─────────────────────────────────────┐
│ Challenge Level: ● ● ○              │
│ (Showing moderate difficulty)       │
└─────────────────────────────────────┘
```

### Recovery Mode Indicator
```
┌─────────────────────────────────────┐
│ 💡 Training Focus Mode              │
│ Extra guidance provided             │
└─────────────────────────────────────┘
```

### Copy/Labels
- Difficulty indicator: "Challenge Level"
- Recovery mode: "Training Focus Mode - Extra guidance provided"
- Performance hint: "Adjusting to your skill level"

## Data Model

### Performance Tracking Schema
```json
{
  "userPerformance": {
    "recentScenarios": [
      {
        "scenarioId": "string",
        "outcome": "perfect|good|poor|failed",
        "timestamp": "ISO8601",
        "trustAccuracy": number,
        "choiceSafety": number
      }
    ],
    "skillLevel": "beginner|intermediate|advanced",
    "consecutiveFailures": number,
    "needsRecovery": boolean
  }
}
```

### Scenario Branch Enhancement
```json
{
  "id": "scenario_001",
  "branches": {
    "easy": {
      "stepModifiers": {
        "extraHints": true,
        "clearerWarnings": true,
        "simplifiedChoices": true
      }
    },
    "standard": {
      "stepModifiers": {}
    },
    "hard": {
      "stepModifiers": {
        "subtlerWarnings": true,
        "timePreasure": true,
        "ambiguousChoices": true
      }
    }
  }
}
```

### Adaptive Routing Rules
```json
{
  "routingRules": {
    "perfectStreak": {
      "threshold": 2,
      "action": "route_to_hard",
      "modifier": "+1_difficulty"
    },
    "failureStreak": {
      "threshold": 2,
      "action": "route_to_easy",
      "modifier": "recovery_mode"
    },
    "mixedPerformance": {
      "action": "route_to_standard"
    }
  }
}
```

## State & Async

### Performance Tracker
```dart
class PerformanceTracker {
  List<ScenarioOutcome> recentScenarios;
  SkillLevel currentSkill;
  bool needsRecovery;

  void recordOutcome(ScenarioOutcome outcome);
  SkillLevel calculateSkillLevel();
  DifficultyRoute getNextRoute();
}
```

### Adaptive Router
```dart
class AdaptiveRouter {
  ScenarioBranch selectBranch(
    Scenario scenario,
    PerformanceTracker performance
  );

  Step modifyStep(Step originalStep, BranchModifiers modifiers);
}
```

### Error Handling
- Performance calculation failure → default to standard difficulty
- Missing branch variant → fallback to standard branch
- Invalid performance data → reset to beginner level

## A11y

### Semantic Labels
- Difficulty indicator: "Current challenge level: {level} out of 3"
- Recovery mode: "Training focus mode active, providing extra guidance"
- Performance hint: "Scenario difficulty automatically adjusted"

### Visual Indicators
- Difficulty shown with dots + text (not color-only)
- Recovery mode uses icon + text
- No critical information conveyed only through difficulty indicator

### Screen Reader
- Announce difficulty changes: "Difficulty increased to challenge level"
- Describe recovery mode: "Training focus mode now active"

## Test Plan

### Unit Tests
- `PerformanceTracker.calculateSkillLevel()` with various outcome patterns
- `AdaptiveRouter.selectBranch()` with different performance scenarios
- Performance outcome recording and skill level transitions
- Recovery mode triggering and exit conditions

### Flow Tests
- Complete scenario with perfect performance → verify harder next scenario
- Complete scenario with poor performance → verify easier next scenario
- Consecutive failures → verify recovery mode activation
- Mixed performance → verify standard difficulty maintained

### Golden Tests
- **Performance tracking**: Verify skill level calculations match expected patterns
- **Routing accuracy**: Confirm correct branch selection based on performance
- **Recovery validation**: Ensure recovery mode triggers after 2 consecutive failures

### A11y Tests
- Screen reader announces difficulty changes appropriately
- Visual difficulty indicators work in high contrast mode
- Recovery mode information accessible without visual cues

### Performance
- Performance calculation <100ms
- Branch selection <50ms
- No impact on conversation loading times

## Acceptance Criteria

**GIVEN** a user completes 2 scenarios with perfect trust calibration
**WHEN** they start the next scenario
**THEN** they are routed to a harder branch with increased challenge

**GIVEN** a user fails 2 consecutive scenarios
**WHEN** they start the next scenario
**THEN** recovery mode activates with easier branch and extra guidance

**GIVEN** a user has mixed recent performance
**WHEN** the adaptive router selects their next experience
**THEN** they receive standard difficulty with no special modifications

**GIVEN** performance tracking over time
**WHEN** reviewing routing decisions
**THEN** traces show appropriate difficulty escalation and recovery patterns

## Risks & Mitigations

### Risk: Difficulty Calibration Accuracy
**Likelihood**: High | **Impact**: Medium
**Mitigation**: A/B testing with different algorithms, user feedback collection

### Risk: User Frustration with Dynamic Changes
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Subtle difficulty indicators, gradual transitions, opt-out option

### Risk: Performance Calculation Complexity
**Likelihood**: Low | **Impact**: High
**Mitigation**: Simple initial algorithm, iterative refinement based on data

## Rollout

### Phase 1: Foundation
- Implement performance tracking system
- Create branch variants for 3 pilot scenarios
- Feature flag: `adaptive_difficulty`

### Phase 2: Algorithm Tuning
- Deploy with conservative difficulty adjustments
- Monitor routing decisions and outcomes
- Tune thresholds based on user behavior

### Phase 3: Expansion
- Add branch variants to more scenarios
- Refine performance calculation algorithm
- Scale to full scenario library

## Done When

- [ ] PerformanceTracker implemented tracking recent 5 scenarios
- [ ] AdaptiveRouter selects appropriate difficulty branches
- [ ] Branch variants created for 3 pilot scenarios (easy/standard/hard)
- [ ] Recovery mode triggers after 2 consecutive failures
- [ ] Performance-based routing shows harder paths after 2 perfect scores
- [ ] Difficulty indicator UI provides subtle feedback
- [ ] A11y labels for difficulty and recovery mode
- [ ] Unit tests cover performance calculation edge cases
- [ ] Golden tests verify routing logic matches expected patterns
- [ ] User testing validates appropriate challenge progression

---

**Dependencies**: PRD-01 (Unified Engine), PRD-02 (Trust Calculation)
**Estimated Effort**: 2 weeks
**Owner**: TBD
**Priority**: P1 (Core personalization feature)