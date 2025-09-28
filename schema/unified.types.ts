// PRD-02 v2.1 Unified Conversation Schema
// Authoritative TypeScript types for ScamShield scenarios

export type TrustHint = "too_trusting" | "appropriate" | "too_skeptical";

export interface Choice {
  id: string;
  label: string;
  pressureDelta: number;            // CLAMPED: -15..+15
  trustHint: TrustHint;
  nextStepId: string;
  flags?: string[];
}

export interface Step {
  id: string;
  actor: "scammer" | "ally" | "system";
  text: string;
  choices?: Choice[];
  next?: string;                    // when no choices
  terminal?: boolean;               // leaf; engine routes to debrief
}

export interface Scenario {
  id: string;
  title: string;
  difficulty: "easy" | "medium" | "hard";
  meta: {
    scamType: string;
    locale: string;
    a11yHints?: string[];
  };
  steps: Step[];
  entryStepId: string;
  debrief: {
    redFlagPrimary: string;         // REQUIRED
    redFlagSecondary?: string[];
    teachingPoints: string[];       // 2–4 bullets
    targetTrustRange: [number, number]; // e.g., [40,60]
  };
}

// Game state interfaces
export interface ConversationState {
  scenarioId: string;
  currentStepId: string;
  visitedSteps: string[];
  trust: number;                    // 0-100
  pressure: number;                 // 0-100
  choices: { stepId: string; choiceId: string; }[];
  isCompleted: boolean;
  debriefReady: boolean;
}

export interface TrustPressureTrace {
  stepId: string;
  choiceId: string;
  trustBefore: number;
  trustAfter: number;
  pressureBefore: number;
  pressureAfter: number;
  timestamp: number;
}

// Validation types
export interface ValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

export interface PathValidation {
  reachableSteps: string[];
  terminalSteps: string[];
  orphanedSteps: string[];
  hasDebrief: boolean;
}