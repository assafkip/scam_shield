ScamShield — PRD v0.1 (MVP)
Problem

Scam messages are frequent and evolving; users (esp. 35+) want a private, simple way to check messages and build durable scam-spotting skills.

Users

Adults 35+; privacy-first; low tolerance for ads/permissions.

Non-Goals

No server-side detection; no analytics; not a default SMS handler by default.

Success Metrics (MVP)

T1: App runs offline on Android+iOS; detection result with explainable rule hits.

T2: <2s analyze latency on mid-tier device.

T3: Unit tests: ≥90% coverage of rules; CI green.

T4 (v0.2): Training module completion rate ≥60% of first-time users.

MVP Features (0.1)

Paste/share intake; Android ACTION_PROCESS_TEXT.

Detection engine: regex/heuristics; tactic labels; suggestions.

Scoring: floor + weighted rules + combo bonus; thresholds map to Info/Caution/Strong Warning.

Settings: privacy statement (“No data collected”).

UX Flows

Paste → Analyze → Result card: Risk %, labels, reasons; Learn more (opens tactic explainer).

Android Process Text: selected text → app opens with seeded text → auto-analyze.

Rules (initial)
IDPattern / HeuristicTacticWeight
R001“final warning”, “within \d+ mins”Urgency/Scarcity0.15
R010Authority names (banks, gov, couriers)Authority0.20
R020Shortened/off-domain pay links (bit.ly, upi.me)Foot-in-the-door0.20
R030Gift cards / voucher codesFoot-in-the-door0.20
R040Crypto + guaranteed returnsSocial Proof0.20
R050“Scan” + “QR”Authority0.20
R060“OTP/PIN” + “share/send/tell”Norm Activation0.30

Combo bonus: Authority+Link (+0.10). Score = clamp(floor 0.15 + Σweights + combos, 0..1).
Labels: ≥0.80 Strong Warning; 0.50–0.79 Caution; <0.50 Info.

Privacy & Permissions

No network, no analytics.

Android: ACTION_PROCESS_TEXT, no READ_SMS/Call Log.

iOS: no IdentityLookup in MVP (later).

QA

Unit tests: one per rule, two combos, boundary thresholds.

Manual: iOS simulator; Android emulator; Process Text path; dark mode; large fonts.

Release Plan

0.1 (Sep 4–9): Detection; CI; Android Process Text; docs.

0.2 (Sep 9–13): Training module (5 scenarios), badges, copy.

*   **Implemented in MVP 0.2:** An offline, interactive training flow with 5 scenarios (courier duty, bank KYC, gift card, crypto lure, QR quishing). Each scenario includes choices, immediate feedback, a debrief, and a short recall question to reinforce learning. The module is self-contained and requires no new permissions or network access. Unit tests for the training engine and content integrity have been added.

0.3 (Sep 13–18): Polish, icons, a11y, Play listing draft, internal track.