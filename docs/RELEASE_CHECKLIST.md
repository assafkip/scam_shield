# Release Checklist

This checklist outlines the steps to release the ScamShield app on the Google Play Store and Apple App Store.

## 1. Pre-release

- [ ] **Complete QA Checklist:** Ensure all items in `docs/QA_CHECKLIST.md` are completed and passed.
- [ ] **Generate Store Assets:** Create the app icons, feature graphic, and screenshots as listed in `docs/STORE_ASSETS.md`.
- [ ] **Finalize Pricing:** The recommended price is **$4.99 USD** (one-time purchase).

## 2. Android Release (Google Play Store)

- [ ] **Set up Internal Test Track:**
    - In the Google Play Console, create a new app.
    - Go to **Testing -> Internal testing**.
    - Create a new release and upload the signed App Bundle (`.aab`).
    - Add testers to the release.
- [ ] **Build Signed App Bundle:**
    - Follow the official Flutter documentation to create a signing key.
    - Run `flutter build appbundle` to generate the signed App Bundle.
- [ ] **Fill out Store Listing:** Copy the content from `docs/STORE_ASSETS.md` into the store listing.
- [ ] **Fill out Data Safety:** Copy the answers from `docs/DATA_SAFETY_DRAFT.md`.
- [ ] **Roll out to Production:** After successful testing, promote the release from internal testing to production.

## 3. iOS Release (Apple App Store)

- [ ] **Build Signed IPA:**
    - Follow the official Flutter documentation to configure signing in Xcode.
    - Run `flutter build ipa` to generate the signed IPA.
- [ ] **Create App Store Connect Record:** Create a new app in App Store Connect.
- [ ] **Fill out App Information:** Copy the content from `docs/STORE_ASSETS.md`.
- [ ] **Submit for Review:** Upload the build to App Store Connect and submit for review.

## 4. Post-release

- **Maintenance Note:** This app is released as-is and will not receive ongoing support or updates. It is designed to work offline indefinitely.
