// Trust & Pressure Engine - PRD-02 v2.1
// Core logic for teaching-focused trust/pressure feedback

import type { TrustHint, ConversationState, TrustPressureTrace } from "../../schema/unified.types";

export const TARGET_RANGE: [number, number] = [40, 60];

export function clampPressure(delta: number): number {
  return Math.max(-15, Math.min(15, delta));
}

export interface TrustPressureUpdate {
  trust: number;
  pressure: number;
  trustZone: "too_low" | "optimal" | "too_high";
  pressureZone: "safe" | "caution" | "danger" | "critical";
  trustFeedback: string;
  pressureFeedback: string;
  shouldTriggerHaptic: boolean;
}

export function applyChoice(
  state: { trust: number; pressure: number },
  choice: { pressureDelta: number; trustHint: TrustHint }
): TrustPressureUpdate {
  const prevTrust = state.trust;
  const prevPressure = state.pressure;

  // Apply pressure delta with clamping
  const newPressure = Math.max(0, Math.min(100,
    state.pressure + clampPressure(choice.pressureDelta)));

  // Apply trust adjustment based on hint
  let newTrust = state.trust;
  switch (choice.trustHint) {
    case "too_trusting":
      newTrust = Math.min(100, state.trust + 12); // Increase trust (bad)
      break;
    case "too_skeptical":
      newTrust = Math.max(0, state.trust - 8);    // Decrease trust (also concerning)
      break;
    case "appropriate":
      // Nudge toward target range
      const [targetMin, targetMax] = TARGET_RANGE;
      const targetMid = (targetMin + targetMax) / 2;
      if (state.trust < targetMin) {
        newTrust = Math.min(targetMax, state.trust + 3);
      } else if (state.trust > targetMax) {
        newTrust = Math.max(targetMin, state.trust - 3);
      }
      // Otherwise leave unchanged if already in range
      break;
  }

  // Determine trust zone
  const trustZone = newTrust < TARGET_RANGE[0] ? "too_low" :
                   newTrust > TARGET_RANGE[1] ? "too_high" : "optimal";

  // Determine pressure zone
  const pressureZone = newPressure <= 30 ? "safe" :
                      newPressure <= 60 ? "caution" :
                      newPressure <= 80 ? "danger" : "critical";

  // Generate feedback messages
  const trustFeedback = generateTrustFeedback(newTrust, trustZone, choice.trustHint);
  const pressureFeedback = generatePressureFeedback(newPressure, pressureZone, choice.pressureDelta);

  // Determine if haptic feedback should trigger
  const pressureIncrease = newPressure - prevPressure;
  const shouldTriggerHaptic = pressureIncrease >= 5;

  return {
    trust: newTrust,
    pressure: newPressure,
    trustZone,
    pressureZone,
    trustFeedback,
    pressureFeedback,
    shouldTriggerHaptic
  };
}

function generateTrustFeedback(trust: number, zone: string, hint: TrustHint): string {
  switch (zone) {
    case "too_high":
      return hint === "too_trusting" ?
        "You're trusting too easily" :
        `Trust level high (${Math.round(trust)}%)`;
    case "too_low":
      return hint === "too_skeptical" ?
        "Healthy skepticism" :
        `Trust level low (${Math.round(trust)}%)`;
    case "optimal":
      return hint === "appropriate" ?
        "Good judgment" :
        `On target (${Math.round(trust)}%)`;
    default:
      return `Trust: ${Math.round(trust)}%`;
  }
}

function generatePressureFeedback(pressure: number, zone: string, delta: number): string {
  if (delta >= 5) {
    return `Pressure spike: ${Math.round(pressure)}% (+${Math.round(delta)})`;
  } else if (delta <= -5) {
    return `Pressure reduced: ${Math.round(pressure)}% (${Math.round(delta)})`;
  }

  switch (zone) {
    case "critical":
      return `High pressure: ${Math.round(pressure)}%`;
    case "danger":
      return `Pressure building: ${Math.round(pressure)}%`;
    case "caution":
      return `Moderate pressure: ${Math.round(pressure)}%`;
    case "safe":
      return `Low pressure: ${Math.round(pressure)}%`;
    default:
      return `Pressure: ${Math.round(pressure)}%`;
  }
}

export function createTrustPressureTrace(
  stepId: string,
  choiceId: string,
  before: { trust: number; pressure: number },
  after: { trust: number; pressure: number }
): TrustPressureTrace {
  return {
    stepId,
    choiceId,
    trustBefore: before.trust,
    trustAfter: after.trust,
    pressureBefore: before.pressure,
    pressureAfter: after.pressure,
    timestamp: Date.now()
  };
}

export function analyzeTrustPerformance(finalTrust: number): {
  category: "too_trusting" | "too_skeptical" | "well_calibrated";
  message: string;
  recommendation: string;
} {
  const [targetMin, targetMax] = TARGET_RANGE;

  if (finalTrust > targetMax) {
    return {
      category: "too_trusting",
      message: `You trusted too easily (${Math.round(finalTrust)}%). Target range is ${targetMin}-${targetMax}%.`,
      recommendation: "Be more skeptical of urgent requests and verify through official channels."
    };
  } else if (finalTrust < targetMin) {
    return {
      category: "too_skeptical",
      message: `You were very cautious (${Math.round(finalTrust)}% trust). Target range is ${targetMin}-${targetMax}%.`,
      recommendation: "Some caution is good, but don't miss legitimate communications."
    };
  } else {
    return {
      category: "well_calibrated",
      message: `Excellent trust calibration (${Math.round(finalTrust)}%). You're in the optimal range.`,
      recommendation: "Keep practicing this balanced approach to build confidence."
    };
  }
}

export function analyzePressureResistance(traces: TrustPressureTrace[]): {
  resistanceScore: number;
  message: string;
  timeline: { step: string; action: "escalated" | "resisted"; delta: number }[];
} {
  const timeline = traces.map(trace => ({
    step: trace.stepId,
    action: (trace.pressureAfter > trace.pressureBefore) ? "escalated" as const : "resisted" as const,
    delta: trace.pressureAfter - trace.pressureBefore
  }));

  const escalations = timeline.filter(t => t.action === "escalated").length;
  const resistances = timeline.filter(t => t.action === "resisted").length;
  const total = escalations + resistances;

  const resistanceScore = total > 0 ? (resistances / total) * 100 : 50;

  let message: string;
  if (resistanceScore >= 70) {
    message = `Excellent pressure resistance! You resisted ${resistances} manipulation attempts vs ${escalations} escalations.`;
  } else if (resistanceScore >= 40) {
    message = `Good pressure awareness. You resisted ${resistances} times but fell for ${escalations} pressure tactics.`;
  } else {
    message = `Scammer escalated pressure ${escalations} times; you resisted only ${resistances} times.`;
  }

  return { resistanceScore, message, timeline };
}