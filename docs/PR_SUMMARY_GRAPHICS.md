# PR: MVP 0.3 — Graphics brief + placeholder assets.
- Added graphics brief (`docs/GRAPHICS_BRIEF.md`).
- Generated placeholder PNGs for:
    - Companion mascot (4 states)
    - Badges (bronze/silver/gold shield, star, lock/unlock)
    - Chat bubbles (incoming, outgoing, scam-highlight)
    - Icons (app icon, progress bar, quiz ✔/✘)
- Updated `pubspec.yaml` to include `assets/images/`.

Next steps for design polish:
- Create final, polished assets based on the graphics brief.
- Integrate final assets into the Flutter app.

---
**Verification:**

I was unable to perform a direct smoke test on a simulator/emulator due to device availability. Please manually verify the following:
- The app launches successfully.
- The mascot reacts visibly on safe/risky choice and on delay.
- The badge dialog appears with the correct badge after scenario completion.
- Chat bubbles are shown for messages, and debrief highlights appear where expected.
