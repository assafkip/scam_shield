# PRD-06: Social Proof & Meaningful Timers

## Goal
Implement inline social proof mechanisms (fake testimonials, group chat illusions) and meaningful countdown timers that actually change conversation outcomes based on user response speed.

## Why Now
Scammers use social proof ("others fell for this") and time pressure as core manipulation tactics. Current scenarios lack these psychological elements, reducing training effectiveness for real-world pressure situations.

## Scope

### In Scope
- Inline social proof widgets (testimonials, group reactions, "others" messages)
- Meaningful countdown timers that affect conversation branching
- Timer-based pressure escalation system
- Social proof resistance training components
- Performance tracking for timed decisions

### Out of Scope
- Real social features or multiplayer
- External social media integration
- Advanced timer algorithms (basic countdown sufficient)
- Social proof across different scenarios

## UX

### Social Proof Examples

**Fake Testimonials:**
```
┌─────────────────────────────────────┐
│ 💬 "This bank helped me recover my  │
│    stolen funds in 24 hours!"      │
│    - Sarah M., verified customer    │
└─────────────────────────────────────┘
```

**Group Chat Illusion:**
```
┌─────────────────────────────────────┐
│ Mike: I just got my refund!         │
│ Lisa: Same here, they're legit      │
│ You:  [How do I sign up?]          │
└─────────────────────────────────────┘
```

**Meaningful Timer:**
```
┌─────────────────────────────────────┐
│ ⏰ URGENT: Respond in 2:15          │
│ Account will be locked if no reply  │
│ [Verify Now] [Ask Questions]        │
└─────────────────────────────────────┘
```

### Timer Outcomes
- **Fast response (<30s)**: Routes to pressure/compliance path
- **Thoughtful delay (30s-2min)**: Routes to verification path  
- **Timeout (>2min)**: Routes to escalation/consequence path

## Data Model

### Social Proof Configuration
```json
{
  "socialProofElements": [
    {
      "type": "testimonial",
      "id": "testimonial_001",
      "content": "This service saved me $2000!",
      "author": "Jennifer K.",
      "credibilityMarkers": ["verified", "5_star_rating"],
      "pressureIncrease": 8
    },
    {
      "type": "group_consensus",
      "id": "group_001",
      "participants": ["Mike", "Lisa", "Dave"],
      "messages": [
        "Mike: This worked for me",
        "Lisa: Same, totally legit",
        "Dave: Just got my money back!"
      ],
      "pressureIncrease": 12
    }
  ]
}
```

### Timer Configuration
```json
{
  "meaningfulTimers": [
    {
      "id": "urgent_timer_001",
      "duration": 120,
      "warningText": "Account will be locked",
      "outcomes": {
        "fast_response": {
          "threshold": 30,
          "nextStepId": "pressure_path",
          "pressureDelta": 15
        },
        "thoughtful_response": {
          "threshold": 120,
          "nextStepId": "verification_path",
          "pressureDelta": 5
        },
        "timeout": {
          "nextStepId": "escalation_path",
          "consequence": "account_locked_illusion"
        }
      }
    }
  ]
}
```

## State & Async

### Social Proof Manager
```dart
class SocialProofManager {
  void displayProofElement(SocialProofConfig config);
  bool userResisted(SocialProofElement element);
  double calculateResistanceScore();
}
```

### Timer System
```dart
class MeaningfulTimer {
  Duration remainingTime;
  TimerOutcome outcomes;
  StreamController<int> countdownStream;

  void startTimer(Duration duration);
  void handleUserResponse(int responseTime);
  String getNextStepId(int responseTime);
}
```

### Error Handling
- Timer system failure → continue without time pressure
- Social proof loading error → skip element gracefully
- Invalid timer configuration → use default 60s timer

## A11y

### Timer Accessibility
- Timer countdown announced every 30 seconds
- "Time remaining: X minutes Y seconds"
- Timer pressure described: "Urgent response requested"
- Option to disable timers for accessibility needs

### Social Proof Labels
- Testimonials: "User testimonial: {content} - {author}"
- Group consensus: "Group conversation showing {participant_count} people"
- Resistance options: "Question this social proof" button

### Focus Management
- Timer countdown doesn't steal focus
- Social proof elements properly integrated in tab order
- Timer warnings don't interrupt screen reader flow

## Test Plan

### Unit Tests
- `MeaningfulTimer.handleUserResponse()` with various response times
- `SocialProofManager.calculateResistanceScore()` with different user actions
- Timer outcome routing based on response speed
- Social proof pressure calculation accuracy

### Flow Tests
- Complete conversation with active countdown timer
- Social proof resistance training effectiveness
- Timer timeout handling and consequence delivery
- Pressure escalation through combined social proof + timers

### Golden Tests
- **Timer effectiveness**: Response times correlate with outcome paths
- **Social proof resistance**: Users can identify and resist fake social proof
- **Pressure correlation**: Combined social proof + timers increase measured pressure

### A11y Tests
- Timer countdown accessible to screen readers
- Social proof elements don't rely on visual-only cues
- Disability-friendly timer options available

### Performance
- Timer system adds <20ms overhead
- Social proof rendering <100ms
- Countdown animations maintain 60fps

## Acceptance Criteria

**GIVEN** a conversation with meaningful timers
**WHEN** user responds quickly (<30s)
**THEN** they are routed to pressure/compliance conversation path

**GIVEN** social proof elements in conversation
**WHEN** user encounters fake testimonials or group consensus
**THEN** pressure meter increases and resistance options are available

**GIVEN** a timer timeout scenario
**WHEN** user fails to respond within time limit
**THEN** conversation routes to escalation path with realistic consequences

**GIVEN** combined social proof and time pressure
**WHEN** both elements are active simultaneously
**THEN** pressure escalation exceeds either element alone

## Risks & Mitigations

### Risk: Timer-Induced User Stress
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Accessibility option to disable timers, clear "this is training" context

### Risk: Social Proof Realism vs Ethics
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Clear educational disclaimers, focus on resistance training

### Risk: Performance Impact of Timers
**Likelihood**: Low | **Impact**: Medium
**Mitigation**: Efficient timer implementation, performance monitoring

## Rollout

### Phase 1: Timer System
- Implement meaningful countdown timers
- Add timer-based conversation routing
- Feature flag: `meaningful_timers`

### Phase 2: Social Proof
- Build social proof element system
- Add resistance training components
- Test pressure calculation accuracy

### Phase 3: Integration
- Combine timers with social proof
- Validate pressure escalation
- Optimize for accessibility

## Done When

- [ ] Meaningful timer system routes conversations based on response speed
- [ ] Social proof elements (testimonials, group consensus) increase pressure
- [ ] Timer timeouts lead to realistic escalation consequences
- [ ] Social proof resistance training options available
- [ ] Combined timer + social proof creates measurable pressure escalation
- [ ] A11y support for timer countdown and social proof elements
- [ ] Performance benchmarks met for timer and social proof systems
- [ ] User testing confirms increased psychological realism
- [ ] Golden tests verify timer outcomes and social proof resistance
- [ ] Accessibility options allow timer disable for users who need it

---

**Dependencies**: PRD-01 (Unified Engine), PRD-02 (Pressure Meter)
**Estimated Effort**: 2 weeks
**Owner**: TBD
**Priority**: P1 (Core psychological simulation)