# ScamShield

A privacy-first, offline-only Flutter app that teaches users to spot scam tactics through interactive game-like scenarios.

## Features

- **Offline-Only**: All content loads from local JSON files - no network required
- **Privacy-First**: No analytics, tracking, or data collection
- **Interactive Learning**: Chat-based scenarios with immediate feedback
- **Companion System**: Animated companion that reacts to your choices
- **Progress Tracking**: Earn badges based on performance (Bronze, Silver, Gold, Star)
- **Quick Test**: 10-question assessment to test scam detection skills
- **Accessibility**: Supports screen readers, large text, and dark mode

## How to Run

1. Ensure you have Flutter installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Content Structure

Scenarios are stored in `assets/content/` as JSON files. Each scenario includes:
- Interactive chat steps with user choices
- Immediate feedback on choices
- Debrief explaining scam tactics used
- Quiz questions to reinforce learning
- Tactic tags (authority, urgency, emotion, etc.)

## Supported Platforms

- iOS
- Android
- Web
- macOS
- Windows
- Linux

## Privacy

ScamShield collects no data and requires no network connection. All learning happens locally on your device.

## Architecture

- **Models**: Data structures for scenarios, quizzes, and game state
- **Services**: Content loading from local JSON assets
- **Screens**: Main UI screens (Home, Scenarios, Quiz, etc.)
- **Widgets**: Reusable UI components (Chat bubbles, Companion, etc.)

The app uses a simple state machine to manage scenario progression and companion reactions.