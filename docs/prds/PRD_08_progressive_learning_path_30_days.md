# PRD-08: Progressive Learning Path (30 Days)

## Goal
Create a structured 30-day training curriculum with tutorial progression, daily scenario queue, and performance-based unlocking system.

## Why Now
Random scenario selection doesn't build skills systematically. A progressive learning path ensures users develop from basic scam recognition to handling sophisticated attacks through structured curriculum delivery.

## Scope

### In Scope
- 30-day structured curriculum with weekly themes
- Tutorial sequence (obvious scam → moderate → expert)
- Daily training queue with 5-minute sessions
- Performance-based unlocking system
- Progress tracking and milestone celebration

### Out of Scope
- Adaptive curriculum based on user demographics
- Social learning features
- Calendar integration
- Push notifications for daily training

## UX

### 30-Day Overview
```
Week 1: Foundation (Obvious Scams)
├─ Day 1: Tutorial + 3 basic scenarios
├─ Day 2-7: Daily queue (1 easy scenario)

Week 2: Recognition (Moderate Difficulty)
├─ Day 8: Ambiguous cases introduction
├─ Day 9-14: Daily queue (1 moderate scenario)

Week 3: Expert Training (Sophisticated Attacks)
├─ Day 15: Advanced tactics introduction
├─ Day 16-21: Daily queue (1 hard scenario)

Week 4: Mastery Testing
├─ Day 22-28: Mixed difficulty assessment
├─ Day 29-30: Final certification scenarios
```

### Daily Training Interface
```
┌─────────────────────────────────────┐
│ 📅 DAY 5 TRAINING                   │
│ Week 1: Foundation                  │
│                                     │
│ Today's Goal: Recognize urgency     │
│ Time needed: ~5 minutes             │
│                                     │
│ [Start Today's Training]            │
│ Progress: ████████░░ 80%            │
└─────────────────────────────────────┘
```

### Unlock System
```
┌─────────────────────────────────────┐
│ 🔒 Week 2: Recognition              │
│                                     │
│ Unlock Requirements:                │
│ ✅ Complete Week 1 (7/7 days)       │
│ ✅ Average score: 80%+              │
│ ✅ Time requirement: 24hrs elapsed  │
│                                     │
│ Status: Ready to unlock!            │
│ [Begin Week 2]                      │
└─────────────────────────────────────┘
```

## Data Model

### Curriculum Structure
```json
{
  "progressiveCurriculum": {
    "week1_foundation": {
      "theme": "Obvious Scams",
      "goals": ["Recognize clear red flags", "Build confidence"],
      "days": [
        {
          "day": 1,
          "type": "tutorial_day",
          "scenarios": ["tutorial_obvious", "basic_001", "basic_002"],
          "unlock_requirements": "none"
        },
        {
          "day": 2,
          "type": "daily_training",
          "scenarios": ["basic_003"],
          "unlock_requirements": "day1_complete"
        }
      ]
    },
    "week2_recognition": {
      "theme": "Moderate Difficulty",
      "unlock_requirements": {
        "week1_complete": true,
        "average_score": 80,
        "time_elapsed_hours": 24
      }
    }
  }
}
```

### Progress Tracking
```json
{
  "userProgress": {
    "currentDay": 5,
    "currentWeek": 1,
    "completedDays": [1, 2, 3, 4],
    "weeklyScores": {
      "week1": 85.5,
      "week2": null
    },
    "milestones": [
      {
        "id": "first_week_complete",
        "achieved": false,
        "unlock_date": null
      }
    ],
    "dailyStreak": 4,
    "totalTimeSpent": 23.5
  }
}
```

## State & Async

### Curriculum Manager
```dart
class CurriculumManager {
  ProgressiveWeek getCurrentWeek();
  List<Scenario> getDailyQueue(int dayNumber);
  bool canUnlockWeek(int weekNumber);
  void recordDayCompletion(int day, double score);
}
```

### Progress Tracker
```dart
class ProgressTracker {
  int currentDay;
  Map<int, double> dailyScores;
  List<Milestone> achievedMilestones;

  bool isDayUnlocked(int day);
  double getWeeklyAverage(int week);
  Duration getTimeToNextUnlock();
}
```

### Error Handling
- Progress corruption → restore from last valid checkpoint
- Unlock calculation failure → manual review mode
- Scenario loading failure → substitute equivalent difficulty

## A11y

### Progress Accessibility
- Weekly progress: "Week {number}: {theme}, {completed} of {total} days complete"
- Daily status: "Day {number}: {status}, estimated time {minutes} minutes"
- Unlock status: "Week {number} unlocks in {time_remaining}"

### Navigation Support
- Skip to current day option
- Week overview with keyboard navigation
- Progress summary available on demand

## Test Plan

### Unit Tests
- `CurriculumManager.canUnlockWeek()` with various progress states
- `ProgressTracker.getWeeklyAverage()` calculation accuracy
- Daily queue generation for each curriculum week
- Unlock requirement validation logic

### Flow Tests
- Complete 30-day curriculum progression
- Week unlocking based on performance requirements
- Daily training queue delivery and completion
- Progress persistence across app sessions

### Golden Tests
- **Progression accuracy**: Users advance appropriately through difficulty levels
- **Unlock fairness**: Requirements are achievable but meaningful
- **Time commitment**: Daily sessions consistently ~5 minutes

### A11y Tests
- Screen reader access to progress information
- Keyboard navigation through curriculum structure
- Clear announcement of unlock achievements

### Performance
- Daily queue loading <200ms
- Progress calculation <100ms
- Curriculum state persistence reliable

## Acceptance Criteria

**GIVEN** a new user starts the progressive learning path
**WHEN** they complete the tutorial and Day 1
**THEN** Day 2 unlocks with appropriate difficulty level

**GIVEN** a user completes Week 1 with 80%+ average
**WHEN** 24 hours have elapsed since Week 1 completion
**THEN** Week 2 unlocks with moderate difficulty scenarios

**GIVEN** daily training sessions
**WHEN** users complete their daily queue
**THEN** sessions consistently take ~5 minutes and provide meaningful challenge

**GIVEN** the 30-day curriculum structure
**WHEN** users progress through weeks
**THEN** difficulty progression from obvious → moderate → expert → mixed is maintained

## Risks & Mitigations

### Risk: User Dropout After Week 1
**Likelihood**: High | **Impact**: High
**Mitigation**: Engaging content, milestone celebrations, achievable daily commitment

### Risk: Difficulty Calibration Errors
**Likelihood**: Medium | **Impact**: Medium
**Mitigation**: Extensive testing with target users, iterative difficulty adjustment

### Risk: 30-Day Commitment Too Long
**Likelihood**: Medium | **Impact**: High
**Mitigation**: Optional accelerated path, flexible scheduling, clear value communication

## Rollout

### Phase 1: Foundation
- Build curriculum structure and progression logic
- Implement Week 1 foundation content
- Feature flag: `progressive_curriculum`

### Phase 2: Full Curriculum
- Complete all 4 weeks of content
- Add unlock system and progress tracking
- Test full 30-day progression

### Phase 3: Optimization
- Monitor completion rates and dropout points
- Optimize difficulty progression
- Add engagement features

## Done When

- [ ] 30-day curriculum implemented with weekly themes and progression
- [ ] Tutorial sequence guides users from obvious scams to expert level
- [ ] Daily training queue delivers ~5 minute sessions
- [ ] Performance-based unlocking requires meaningful achievement
- [ ] Progress tracking shows completion status and weekly averages
- [ ] Week 1 unlocks immediately, subsequent weeks require performance + time
- [ ] A11y support for curriculum navigation and progress reporting
- [ ] User testing validates 5-minute daily commitment is sustainable
- [ ] Golden tests verify appropriate difficulty progression
- [ ] Completion celebration and milestone system encourages continued engagement

---

**Dependencies**: PRD-01 (Unified Engine), PRD-03 (Adaptive Difficulty)
**Estimated Effort**: 2 weeks
**Owner**: TBD
**Priority**: P1 (Core learning system)