# ScamShield Unified Scenario Schema

PRD-02 v2.1 schema for teaching-focused trust/pressure feedback scenarios.

## Schema Files

- `unified.types.ts` - Authoritative TypeScript definitions
- `unified.schema.json` - JSON Schema for CI validation
- `README.md` - This documentation

## Key Features

### Trust System
- **trustHint**: Categorical feedback (`"too_trusting"`, `"appropriate"`, `"too_skeptical"`)
- **targetTrustRange**: Debrief shows ideal range (e.g., `[40, 60]`)
- Engine maps trustHint to internal 0-100 trust score

### Pressure System
- **pressureDelta**: Standardized -15 to +15 range
- Engine clamps and tracks 0-100 pressure level
- Haptic feedback triggers on ≥5 point increases

### Difficulty Progression
- **easy**: ≤3 choices per step, obvious red flags
- **medium**: ≤5 choices per step, mixed signals
- **hard**: ≤7 choices per step, advanced tactics

### Debrief Requirements
- **redFlagPrimary**: Required single most important red flag
- **teachingPoints**: 2-4 bullet points explaining manipulation
- **targetTrustRange**: Shows optimal trust calibration

## Validation

All scenarios must:
1. Pass JSON Schema validation
2. Have all choice paths lead to terminal steps
3. Include complete debrief information
4. Respect difficulty choice limits
5. Contain no legacy fields (`suspicionIncrease`, `resistanceIncrease`, `trustScore`)

## Migration

Legacy scenarios are converted via `tools/convert-legacy.ts`:
- Maps old pressure fields to standardized `pressureDelta`
- Converts numeric trust scores to categorical `trustHint`
- Ensures all paths terminate properly
- Adds placeholder debrief content for manual completion