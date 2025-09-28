# ScamShield GDevelop Edition

Educational scam detection game built with GDevelop 5. Fully offline, privacy-first, chat-based learning experience.

## Quick Start

1. **Install GDevelop 5** from [gdevelop.io](https://gdevelop.io)
2. **Open Project**: File → Open Project → `ScamShield-gd/project.json`
3. **Preview**: Click the Preview button to test in browser
4. **Export**: Use GDevelop's export features for Android/iOS

## Project Structure

```
ScamShield-gd/
├── project.json              # Main GDevelop project file
├── assets/
│   ├── content/               # Scenario JSON files
│   │   ├── content_index.json # List of all scenarios to load
│   │   ├── y01_dating.json    # Youth scenario: dating scam
│   │   ├── y02_sextortion.json # Youth scenario: sextortion
│   │   └── quicktest.json     # SDAT-10 assessment questions
│   ├── images/
│   │   ├── mascot/            # Companion character (4 emotions)
│   │   ├── bubbles/           # Chat bubble graphics
│   │   ├── badges/            # Achievement badges
│   │   └── bg/                # Background images by context
│   └── fonts/                 # Custom fonts (optional)
└── docs/
    ├── README.md              # This file
    └── PRIVACY.md             # Privacy policy
```

## Game Flow

1. **Boot Scene**: Loads all scenario content from JSON files
2. **Home Scene**: Main menu with options for training, quick test, privacy
3. **MenuYouth**: Select from youth-focused scenarios
4. **MenuCapsules**: Select from general adult scenarios  
5. **PlayScene**: Chat-based scenario gameplay with mascot reactions
6. **QuickTest**: 10-question SDAT assessment with scoring

## Scenes Overview

### Boot Scene
- Loads `content_index.json` to get list of scenario files
- Parses each JSON scenario into global Registry variable
- Transitions to Home scene when loading complete

### PlayScene (Main Gameplay)
- Chat bubble display for scammer messages
- Tappable reply chips for user choices
- Mascot reactions: neutral → happy/sad/concerned based on choices
- Debrief cards explaining scam tactics
- Quiz questions with correct/incorrect feedback
- Badge popup with achievement celebration

### Storage
- Uses GDevelop's local storage (no cloud sync)
- Saves: completed scenarios, earned badges, user preferences
- No personal information or quiz answers stored

## Development Notes

### Adding New Scenarios
1. Create JSON file following the schema in `y01_dating.json`
2. Add filename to `content_index.json`
3. Ensure proper tactic tags and context classification

### Mascot State Machine
- `neutral`: Default state
- `happy`: Safe choice made
- `sad`: Risky choice made  
- `concerned`: 3+ seconds idle during choice

### Badge Logic
- **Gold**: All safe choices + perfect quiz score
- **Silver**: Mostly safe choices + high quiz score
- **Bronze**: Some correct answers
- **Star**: Perfect gold badge overlay

## Export Settings

### Android (APB/AAB)
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest supported by GDevelop
- Remove internet permissions in manifest

### iOS
- Minimum version: iOS 12
- Ensure no network capabilities in Info.plist

## Privacy Compliance

- ✅ No data collection or transmission
- ✅ Fully offline operation
- ✅ No analytics or tracking
- ✅ No account creation required
- ✅ Local storage only (progress/badges)

## Testing Checklist

- [ ] Boot scene loads all scenarios successfully
- [ ] Menu scenes populate with correct scenario lists
- [ ] PlayScene chat flow works (prompt → choice → feedback → debrief → quiz)
- [ ] Mascot reacts appropriately to safe/risky choices
- [ ] Badge calculation and popup display correctly
- [ ] QuickTest runs full 10 questions and shows score
- [ ] Privacy page displays static content
- [ ] App exports and runs offline on target platforms
- [ ] No network requests made during gameplay
- [ ] Large text setting doesn't break UI layout

## Content Schema

See `assets/content/y01_dating.json` for the complete JSON schema. Key fields:

- `id`: Unique scenario identifier
- `title`: Display name
- `context`: Theme (dating, job, crypto, etc.)
- `tacticTags`: Scam tactics used
- `steps`: Chat conversation with choices
- `debrief`: Educational explanation 
- `quiz`: Assessment questions
- `provenance`: Source attribution

## Support

For GDevelop-specific issues, see [GDevelop Community](https://community.gdevelop.io).

For ScamShield content questions, see project documentation.