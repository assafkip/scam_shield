# Release Checklist — Minimal Maintenance

## Pricing & Monetization
- Set price: $4.99 (one-time). No IAP, no subscriptions, no ads.

## QA
- `flutter analyze` clean; `flutter test` ≥ 90% scenario engine coverage.
- Manual: Android emulator + iOS simulator; large fonts; dark mode; VoiceOver/TalkBack; low-end device perf.
- Cold start < 2s; scenario start < 1s; no jank in interactions.

## Assets
- App icon, feature graphic, splash (placeholders acceptable).
- Screenshots: Home, Scenario, Debrief, Badge.
- Store copy: use `/docs/store_listing.md`.

## Compliance
- Privacy policy: `/docs/PRIVACY.md` (host via GitHub Pages if required).
- Data Safety: fill Play Console from `/docs/DATA_SAFETY_DRAFT.md`.
- iOS App Store Privacy: “Data Not Collected”.

## Build & Sign
- Android: `flutter build appbundle` → upload AAB to Play Console (Internal testing first).
- iOS: `flutter build ios` (archive via Xcode for App Store Connect).
- Keep signing keys local; do not commit secrets.

## Listing
- Paste Title/Short/Full Description from `/docs/store_listing.md`.
- Set category: Education or Simulation (whichever aligns with store guidance).
- Add privacy policy URL (GitHub Pages) and screenshots.

## Post-Release
- Pin a README note: stand-alone, offline; no ongoing updates promised.
- Optional: enable automated price promotions via storefront tools.