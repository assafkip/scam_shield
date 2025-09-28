# ScamShield PRD Index
*Strategic Product Roadmap: Current → Ideal*

## Overview

This directory contains 10 iterative PRDs that transform ScamShield from its current fragmented state to a unified, accessible, and educationally effective anti-scam training platform. Each PRD is independently valuable, 1-2 week scope, and testable.

## Sequence & Dependencies

### Phase 1: Foundation (PRD-01 to PRD-03)
**Goal**: Establish unified architecture and core psychological simulation

**PRD-01: Unified Conversation Engine v1** *(2 weeks, P0)*
- Consolidates three competing conversation systems into one engine
- Single JSON schema with backward compatibility
- **Why critical**: Blocks all other improvements; architectural debt removal
- **Dependencies**: None (foundational)

**PRD-02: Trust-from-Choices & Pressure Meter** *(1.5 weeks, P1)*
- Removes explicit trust sliders, infers trust from choice semantics
- Live pressure meter responding to manipulative tactics
- **Why now**: More realistic psychological simulation than artificial sliders
- **Dependencies**: PRD-01

**PRD-03: Adaptive Branching & Dynamic Difficulty** *(2 weeks, P1)*
- Performance-based conversation routing adjusts challenge level
- Recovery paths for struggling users, harder branches for advanced users
- **Why now**: Personalized learning maximizes educational effectiveness
- **Dependencies**: PRD-01, PRD-02

### Phase 2: Content & Immersion (PRD-04 to PRD-06)
**Goal**: Deep, authentic scenarios with realistic psychological pressure

**PRD-04: Scenario Depth Upgrade (First 5)** *(2 weeks, P1)*
- Expands 5 priority scenarios to 8-15 message depth with true branching
- Ambiguous cases challenge trust calibration skills
- **Why now**: Shallow scenarios don't simulate real-world scam psychology
- **Dependencies**: PRD-01

**PRD-05: Platform Authenticity Skins** *(1.5 weeks, P2)*
- WhatsApp, Gmail, SMS, Tinder, Instagram visual theming without logic duplication
- Increases immersion through authentic platform resemblance
- **Why now**: Generic chat UI reduces psychological training effectiveness
- **Dependencies**: PRD-01

**PRD-06: Social Proof & Meaningful Timers** *(2 weeks, P1)*
- Inline social proof (fake testimonials, group consensus) and countdown timers that change outcomes
- Core scam psychology tactics: social proof + time pressure
- **Why now**: Missing psychological elements reduce training realism
- **Dependencies**: PRD-01, PRD-02

### Phase 3: Consequences & Learning (PRD-07 to PRD-09)
**Goal**: Realistic outcomes and structured learning progression

**PRD-07: Consequences & Replay** *(1.5 weeks, P1)*
- Realistic financial loss/missed opportunity/success outcomes with replay functionality
- Educational impact through concrete consequences
- **Why now**: Abstract "failure" messages don't create lasting learning
- **Dependencies**: PRD-01, PRD-02

**PRD-08: Progressive Learning Path (30 Days)** *(2 weeks, P1)*
- Structured curriculum: tutorial → daily 5-min training → weekly themes → performance unlocking
- Systematic skill building from obvious scams to expert-level detection
- **Why now**: Random scenarios don't build skills systematically
- **Dependencies**: PRD-01, PRD-03

**PRD-09: Recovery Training** *(1.5 weeks, P2)*
- Post-scam damage control guidance with offline checklists and action steps
- Value even after prevention fails; builds confidence for future protection
- **Why now**: Current training only focuses on prevention, not recovery
- **Dependencies**: PRD-01, PRD-07

### Phase 4: Quality & Accessibility (PRD-10)
**Goal**: Production-ready quality bar and inclusive design

**PRD-10: Accessibility & Quality Bar** *(2 weeks, P0)*
- Automated golden tests (depth ≥8, branching ≥2, tactic coverage) + WCAG 2.1 AA compliance
- Screen reader support, high contrast, keyboard navigation, semantic labeling
- **Why critical**: Ensures all improvements are accessible; quality enforcement
- **Dependencies**: All previous PRDs (final quality layer)

## Critical Path Analysis

**Blocking Path**: PRD-01 → PRD-02 → PRD-03 → PRD-10
- Total: ~7.5 weeks for core functionality + quality
- PRD-01 is the critical blocker enabling all other work

**Parallel Opportunities**:
- PRD-04, PRD-05 can start immediately after PRD-01
- PRD-06 requires PRD-02 (pressure meter dependency)
- PRD-07, PRD-09 can start after PRD-01, PRD-02

## Success Metrics

### Educational Effectiveness
- Scenario depth: ≥90% meet 8+ message requirement
- Branching complexity: ≥90% have 2+ meaningful choice points
- Tactic coverage: All 6 core manipulation tactics represented
- User skill progression: Measurable improvement over 30-day curriculum

### Accessibility Compliance
- WCAG 2.1 AA: 100% compliance across all features
- Screen reader: Full conversation navigation and content access
- Contrast ratios: ≥4.5:1 for all interactive elements
- Keyboard navigation: Complete coverage with visible focus

### Technical Quality
- Performance: <200ms conversation loading, 60fps maintained
- Reliability: <1% conversation state loss or corruption
- Maintainability: Single conversation engine eliminates architectural debt
- Testing: Automated golden tests prevent quality regression

## Risk Summary

**High-Impact Risks**:
- PRD-01 complexity could delay entire roadmap → Mitigation: Incremental migration, extensive testing
- WCAG compliance gaps could exclude users → Mitigation: Expert review, automated checking
- User fatigue with 30-day commitment → Mitigation: 5-min daily sessions, flexible pacing

**Resource Risks**:
- Scenario writing expertise needed for PRD-04 → Mitigation: Expert consultation, iterative improvement
- Accessibility testing requires specialized skills → Mitigation: External audit, automated tooling

## Implementation Notes

### Offline-First Constraint
All PRDs maintain offline functionality with no telemetry or cloud dependencies. Local storage handles all state persistence and progress tracking.

### Feature Flagging Strategy
Each PRD deploys behind feature flags enabling gradual rollout and A/B testing:
- `unified_conversation_pilot` (PRD-01)
- `implicit_trust_system` (PRD-02)
- `adaptive_difficulty` (PRD-03)
- And so forth...

### Content Strategy
PRDs focus on system improvements; content creation (new scenarios) is parallel workstream that benefits from all architectural improvements.

---

**Total Estimated Effort**: 18 weeks (assuming some parallelization)
**Critical Path**: 7.5 weeks for core functionality
**Next Step**: Begin PRD-01 implementation to unblock all subsequent work