ScamShield — PRD v0.4 (Youth Content & SDAT Quiz)

Problem

Scam messages are frequent and evolving; users (esp. 35+) want a private, simple way to check messages and build durable scam-spotting skills. This version expands to include youth-focused content.

Users

Adults 35+; younger users (teens, young adults); privacy-first; low tolerance for ads/permissions.

Non-Goals

No server-side detection; no analytics; no default SMS handler by default.
No new permissions or telemetry.
No dependency bumps.

Success Metrics (MVP)

T1: App runs offline on Android+iOS; training module completion rate ≥60% of first-time users.
T2: <2s analyze latency on mid-tier device (for training module).
T3: Unit tests: ≥90% coverage of scenario engine and new quiz module; CI green.
T4 (v0.4): Youth-focused scenario pack completion rate ≥60% of first-time users.
T5 (v0.4): SDAT quiz completion rate ≥70% of first-time users.

MVP Features (0.4)

Youth-focused Scenario Packs:
- 5 new scenarios (dating/romance, sextortion/catfishing, crypto/investment, marketplace/QR, job/recruiter).
- Each with 3-5 decision points, clear safe/risky branches, debriefs naming tactics, and 1-2 recall quiz items.
- Content loaded from local JSON assets.

SDAT-style 10-item Quiz:
- Fixed 10-item mode (5 scam, 5 not-scam), random order.
- Scoring and summary with short tips.
- Accessible from Home screen.

UI Hooks:
- Home screen "Quick Test (10)" entry.
- Training menu groups "Next-Gen Scams" pack.

A11y & Copy:
- Semantics labels for new buttons and images.
- Bubbles remain readable in large text & dark mode.

QA

Unit tests:
- `test/content_schema_test.dart`: validate JSON files parse; ids unique; required fields present.
- `test/quiz_sdat_test.dart`: scoring correctness and 10/10 star award.
- `test/scenario_flow_youth_test.dart`: golden-path playthrough for 1 scenario.

Manual:
- iOS simulator + Android emulator; large fonts; dark mode; VoiceOver/TalkBack.
- Cold start < 2s; scenario start < 1s; no jank in interactions.
- UI polish verified (mascot reacts on choice, badge dialog after completion, chat bubbles shown).

Release Plan

0.1 (Sep 4–9): Detection; CI; Android Process Text; docs.
0.2 (Sep 9–13): Training module (5 scenarios), badges, copy.
0.3 (Sep 13–18): UI integration (mascot, badges, chat bubbles).
0.4 (Sep 18–25): Youth scenarios + SDAT quiz (offline).
0.5 (Sep 25–Oct 2): Release assets + compliance.
