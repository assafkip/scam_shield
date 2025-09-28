# ScamShield PRD Glossary

## Purpose
This glossary standardizes terminology across all PRDs to prevent language drift and ensure consistent understanding across development, design, and product teams.

---

## Core Architecture Terms

### Conversation
**Definition**: A complete training scenario representing an exchange between a user and potential scammer, consisting of multiple messages and user choices.
**Usage**: "Each conversation follows the unified schema defined in PRD-01"
**Related**: Step, Message, Choice

### Step
**Definition**: A single node in a conversation flow, representing either a message from a sender or a choice point for the user.
**Schema**: `{id, type: "message|choice|end", text, choices[], meta}`
**Usage**: "The conversation advances through steps based on user choices"
**Related**: Conversation, Choice, Message

### Choice
**Definition**: A user response option at a decision point in a conversation, with associated safety rating and consequences.
**Schema**: `{id, text, nextStepId, isSafe, tacticsUsed[], trustDelta, pressureDelta}`
**Usage**: "Safe choices reduce trust level while risky choices increase it"
**Related**: Step, TacticTag, Trust

### Message
**Definition**: Content displayed to the user from a conversation participant (scammer, legitimate entity, system).
**Schema**: `{id, from, text, timestamp}`
**Usage**: "Messages accumulate context that influences user trust decisions"
**Related**: Conversation, Step

---

## Psychology & Training Terms

### Trust
**Definition**: A calculated percentage (0-100%) representing user confidence in message legitimacy, inferred from choice patterns rather than explicit user input.
**Calculation**: Derived from choice safety ratings, contextual factors, and scenario-specific optimal ranges
**Usage**: "Trust level of 85% in a scam scenario indicates over-trusting behavior"
**Related**: Choice, Pressure, TrustDelta

### Pressure
**Definition**: A psychological stress metric (0-100%) that increases based on manipulative tactics present in conversation content.
**Sources**: Time limits, urgency language, authority claims, social proof elements
**Usage**: "Pressure meter escalates as scammers apply multiple manipulation tactics"
**Related**: TacticTag, Timer, SocialProof

### TacticTag
**Definition**: Labels identifying psychological manipulation techniques used in conversation content.
**Standard Set**: authority, urgency, social_proof, emotion, foot_in_door, norm_activation
**Usage**: "Choices tagged with 'urgency' and 'authority' increase pressure by 15 points"
**Related**: Pressure, Choice, SocialProof

### TrustDelta
**Definition**: The impact a specific choice has on calculated trust level, ranging from -20 to +20.
**Logic**: Safe choices have negative delta (reduce trust), risky choices have positive delta (increase trust)
**Usage**: "Sharing personal information has a trustDelta of +15"
**Related**: Trust, Choice

### PressureDelta
**Definition**: The amount a choice or message increases psychological pressure, ranging from 0 to +15.
**Sources**: Tactic detection, time constraints, social proof elements
**Usage**: "Countdown timers add pressureDelta of 12 to the current step"
**Related**: Pressure, TacticTag

---

## User Interface Terms

### Skin
**Definition**: Visual theming that makes conversations resemble authentic platforms (WhatsApp, Gmail, etc.) without changing underlying functionality.
**Components**: Bubble styles, colors, fonts, layouts, avatars
**Usage**: "WhatsApp skin applies green color scheme and rounded message bubbles"
**Related**: Platform, SkinConfig

### SkinConfig
**Definition**: Metadata specifying which visual theme to apply to a conversation and any customization parameters.
**Schema**: `{platform, contactName, avatar, verified, groupChat}`
**Usage**: "SkinConfig specifies 'Bank Security' as contact name with unverified status"
**Related**: Skin, Platform

### Platform
**Definition**: The communication medium being simulated (whatsapp, sms, email, dating, social).
**Purpose**: Determines appropriate visual styling and psychological context
**Usage**: "Email platform scenarios use subject lines and formal addressing"
**Related**: Skin, SkinConfig

---

## Content & Progression Terms

### Scenario
**Definition**: A complete training unit including conversation flow, metadata, quiz questions, and educational context.
**Schema**: Extends Conversation with difficulty, audience, platform, isScam, victimStory, optimalTrust
**Usage**: "Each scenario targets specific demographic and difficulty level"
**Related**: Conversation, Difficulty, Audience

### Difficulty
**Definition**: Challenge level of a scenario on 1-3 scale, determining complexity of manipulation tactics and ambiguity.
**Levels**: 1=Obvious scams, 2=Moderate ambiguity, 3=Sophisticated attacks
**Usage**: "Week 3 scenarios use difficulty 3 with subtle manipulation tactics"
**Related**: Scenario, Branching, Adaptive

### Branching
**Definition**: Multiple conversation paths available based on user choices, creating non-linear scenario progression.
**Requirement**: Golden tests enforce ≥2 meaningful branch points per scenario
**Usage**: "Branching allows different outcomes based on user verification behavior"
**Related**: Choice, Step, AdaptiveRouting

### Depth
**Definition**: Total number of messages/steps in a conversation, with minimum threshold for educational effectiveness.
**Requirement**: Golden tests enforce ≥8 steps for adequate psychological development
**Usage**: "Shallow scenarios lack depth needed for realistic pressure buildup"
**Related**: Scenario, Step, Message

---

## System & Quality Terms

### ConversationEngine
**Definition**: Unified system component that handles all conversation types through single rendering and state management logic.
**Purpose**: Eliminates architectural fragmentation from legacy multiple-engine approach
**Usage**: "ConversationEngine loads scenarios regardless of legacy format differences"
**Related**: Conversation, Step, Migration

### AdaptiveRouting
**Definition**: System that selects conversation difficulty and branching paths based on user's recent performance.
**Logic**: Perfect performance → harder branches, poor performance → easier branches, failures → recovery mode
**Usage**: "AdaptiveRouting increases challenge after consecutive perfect scores"
**Related**: Difficulty, Branching, Performance

### GoldenTest
**Definition**: Automated quality assurance that enforces minimum standards for scenario depth, branching, and tactic coverage.
**Requirements**: ≥8 steps depth, ≥2 branching points, all 6 core tactics represented
**Usage**: "Golden tests prevent deployment of scenarios that don't meet quality bar"
**Related**: Depth, Branching, TacticTag

### ReplayPoint
**Definition**: Saved conversation state that allows users to return to critical decision moments for alternative choices.
**Schema**: `{id, stepId, description, stateSnapshot}`
**Usage**: "Replay points enable learning from mistakes without full scenario restart"
**Related**: Step, ConversationState

---

## Outcome & Assessment Terms

### Consequence
**Definition**: Realistic end-of-scenario outcome showing financial impact, missed opportunities, or successful protection.
**Types**: financial_loss, missed_opportunity, calibrated_success
**Usage**: "Financial loss consequences specify dollar amounts and recovery steps"
**Related**: Scenario, Trust, Recovery

### Recovery
**Definition**: Post-scam guidance providing damage control steps, timelines, and resources for users who fall for scams.
**Components**: Action checklists, contact information, emotional support messaging
**Usage**: "Recovery training triggers automatically when users share sensitive information"
**Related**: Consequence, DamageControl

### Curriculum
**Definition**: Structured 30-day learning progression with weekly themes, daily scenarios, and performance-based unlocking.
**Structure**: Week 1=Foundation, Week 2=Recognition, Week 3=Expert, Week 4=Mastery
**Usage**: "Progressive curriculum ensures systematic skill development over time"
**Related**: Progression, Unlocking, Performance

### Performance
**Definition**: User skill assessment based on recent scenario outcomes, trust calibration accuracy, and choice safety patterns.
**Tracking**: Recent 5 scenarios, trust accuracy, choice safety scores
**Usage**: "Performance tracking determines adaptive difficulty routing decisions"
**Related**: AdaptiveRouting, Trust, SkillLevel

---

## Technical Terms

### A11y
**Definition**: Accessibility features ensuring application usability for users with disabilities, following WCAG 2.1 AA standards.
**Components**: Screen reader support, high contrast, keyboard navigation, semantic labels
**Usage**: "A11y compliance requires 4.5:1 contrast ratios for all interactive elements"
**Related**: WCAG, SemanticLabel, Contrast

### SemanticLabel
**Definition**: Accessibility markup that provides screen reader users with context about UI elements and their purpose.
**Format**: "Element type: content description, current state"
**Usage**: "Message bubbles need semantic labels identifying sender and content"
**Related**: A11y, ScreenReader

### FeatureFlag
**Definition**: Configuration toggle that enables gradual rollout and A/B testing of new functionality.
**Naming**: Each PRD has associated feature flag (e.g., `unified_conversation_pilot`)
**Usage**: "Feature flags allow testing new conversation engine with subset of users"
**Related**: Rollout, ABTest

---

## Measurement Terms

### ConversionRate
**Definition**: Percentage of users who complete target actions (scenario completion, curriculum progression, skill improvement).
**Usage**: "30-day curriculum aims for >60% completion conversion rate"

### RetentionRate
**Definition**: Percentage of users who return for continued training after initial session.
**Measurement**: Daily, weekly, and monthly cohort retention
**Usage**: "Daily retention indicates immediate engagement effectiveness"

### TrustAccuracy
**Definition**: How closely user's final trust level matches expert-determined optimal range for scenario.
**Calculation**: Distance from optimal trust range, normalized to percentage
**Usage**: "Trust accuracy >80% indicates effective calibration training"

---

**Document Maintenance**: Add new terms as they emerge during PRD implementation
**Change Process**: Updates require review by product and engineering leads
**Last Updated**: 2025-09-21