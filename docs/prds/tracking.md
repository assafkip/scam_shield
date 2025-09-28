# PRD Tracking & Project Management

## Project Status Overview

| PRD | Title | Owner | Status | Start Date | Target End | Effort | Priority | PR Links |
|-----|-------|-------|--------|------------|------------|--------|----------|----------|
| PRD-01 | Unified Conversation Engine v1 | TBD | Not Started | TBD | TBD | 2 weeks | P0 | - |
| PRD-02 | Trust-from-Choices & Pressure Meter | TBD | Not Started | TBD | TBD | 1.5 weeks | P1 | - |
| PRD-03 | Adaptive Branching & Dynamic Difficulty | TBD | Not Started | TBD | TBD | 2 weeks | P1 | - |
| PRD-04 | Scenario Depth Upgrade (First 5) | TBD | Not Started | TBD | TBD | 2 weeks | P1 | - |
| PRD-05 | Platform Authenticity Skins | TBD | Not Started | TBD | TBD | 1.5 weeks | P2 | - |
| PRD-06 | Social Proof & Meaningful Timers | TBD | Not Started | TBD | TBD | 2 weeks | P1 | - |
| PRD-07 | Consequences & Replay | TBD | Not Started | TBD | TBD | 1.5 weeks | P1 | - |
| PRD-08 | Progressive Learning Path (30 Days) | TBD | Not Started | TBD | TBD | 2 weeks | P1 | - |
| PRD-09 | Recovery Training | TBD | Not Started | TBD | TBD | 1.5 weeks | P2 | - |
| PRD-10 | Accessibility & Quality Bar | TBD | Not Started | TBD | TBD | 2 weeks | P0 | - |

## Status Definitions

- **Not Started**: PRD approved, awaiting resource allocation
- **In Progress**: Active development, on track
- **Code Review**: Implementation complete, under review
- **Merged**: Completed and deployed behind feature flag
- **Blocked**: Waiting on dependencies or external factors
- **At Risk**: Experiencing delays or scope challenges

## Critical Path Timeline

### Phase 1: Foundation (0-6 weeks)
```
Week 1-2:  PRD-01 (Unified Engine) - CRITICAL BLOCKER
Week 3-4:  PRD-02 (Trust & Pressure) - Depends on PRD-01
Week 5-6:  PRD-03 (Adaptive Difficulty) - Depends on PRD-01, PRD-02
```

### Phase 2: Content & Immersion (2-10 weeks, some parallel)
```
Week 3-4:  PRD-04 (Scenario Depth) - Can start after PRD-01
Week 4-5:  PRD-05 (Platform Skins) - Can start after PRD-01
Week 7-8:  PRD-06 (Social Proof) - Depends on PRD-02
```

### Phase 3: Learning & Recovery (6-12 weeks)
```
Week 9-10:   PRD-07 (Consequences) - Depends on PRD-01, PRD-02
Week 11-12:  PRD-08 (30-Day Path) - Depends on PRD-01, PRD-03
Week 11-12:  PRD-09 (Recovery) - Depends on PRD-01, PRD-07
```

### Phase 4: Quality (12-14 weeks)
```
Week 13-14: PRD-10 (A11y & Quality) - Depends on ALL previous PRDs
```

## Dependency Matrix

| PRD | Blocks | Blocked By |
|-----|--------|------------|
| PRD-01 | ALL others | None |
| PRD-02 | PRD-03, PRD-06, PRD-07 | PRD-01 |
| PRD-03 | PRD-08 | PRD-01, PRD-02 |
| PRD-04 | None | PRD-01 |
| PRD-05 | None | PRD-01 |
| PRD-06 | None | PRD-01, PRD-02 |
| PRD-07 | PRD-09 | PRD-01, PRD-02 |
| PRD-08 | None | PRD-01, PRD-03 |
| PRD-09 | None | PRD-01, PRD-07 |
| PRD-10 | None | ALL others |

## Resource Planning

### Skills Required
- **Flutter/Dart Development**: All PRDs
- **UX/UI Design**: PRD-05 (Platform Skins), PRD-10 (Accessibility)
- **Educational Content**: PRD-04 (Scenario Writing), PRD-08 (Curriculum Design)
- **Accessibility Expertise**: PRD-10 (WCAG Compliance)
- **Psychology/Security**: PRD-06 (Social Proof), PRD-09 (Recovery)

### Estimated Team Capacity
- **1 Senior Flutter Developer**: Can handle PRD-01, PRD-02, PRD-03 sequentially
- **1 Mid-level Developer**: Can work on PRD-04, PRD-05 in parallel with senior work
- **1 UX/Content Specialist**: Required for PRD-04, PRD-05, PRD-08
- **1 Accessibility Consultant**: Required for PRD-10 (can be external)

## Feature Flag Strategy

| PRD | Feature Flag | Rollout Strategy |
|-----|--------------|------------------|
| PRD-01 | `unified_conversation_pilot` | 2 scenarios → 10% users → full rollout |
| PRD-02 | `implicit_trust_system` | A/B test vs current sliders |
| PRD-03 | `adaptive_difficulty` | Conservative algorithm → tuning |
| PRD-04 | `deep_scenarios_pilot` | 5 enhanced scenarios |
| PRD-05 | `platform_skins` | WhatsApp + SMS first |
| PRD-06 | `meaningful_timers` | Timer-optional → full pressure |
| PRD-07 | `realistic_consequences` | Financial scenarios first |
| PRD-08 | `progressive_curriculum` | Week 1 only → full 30 days |
| PRD-09 | `recovery_training` | Post-scam trigger testing |
| PRD-10 | `quality_enforcement` | Dev tools first → user-facing |

## Risk Tracking

### Current Active Risks
*None - PRDs not yet started*

### Potential Risks by PRD
- **PRD-01**: High complexity, potential for scope creep → Mitigation: Incremental approach
- **PRD-04**: Content creation bottleneck → Mitigation: Expert consultation early
- **PRD-06**: User stress from timers → Mitigation: Accessibility options, user testing
- **PRD-08**: 30-day commitment too long → Mitigation: Flexible pacing, value demonstration
- **PRD-10**: WCAG compliance gaps → Mitigation: External audit, automated tooling

## Weekly Reporting Template

### Week of [Date]
**Completed This Week:**
- PRD-XX: [Milestone completed]

**In Progress:**
- PRD-XX: [Current status and % complete]

**Blockers:**
- [Description of any blocking issues]

**Next Week Plan:**
- [Key milestones targeted for next week]

**Risks/Concerns:**
- [Any new risks or changes to existing risks]

---

## How to Update This Document

1. **Status Changes**: Update the main tracking table when PRD status changes
2. **Timeline Updates**: Adjust start/end dates based on actual progress
3. **Risk Updates**: Add new risks to risk tracking section with mitigation plans
4. **PR Links**: Add GitHub PR links when development begins
5. **Owner Assignment**: Update owner field when resources are allocated

**Document Owner**: Product Manager
**Review Frequency**: Weekly during active development
**Last Updated**: 2025-09-21