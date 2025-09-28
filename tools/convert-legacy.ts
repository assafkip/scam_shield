#!/usr/bin/env ts-node
// Legacy to Unified Schema Converter - PRD-02 v2.1
// Idempotent: re-run safe. Leaves already-unified files intact.

import { readFileSync, writeFileSync, readdirSync, existsSync } from "fs";
import { join } from "path";
import type { Scenario, Step, Choice, TrustHint } from "../schema/unified.types";

function mapPressure(x: any): number {
  // Heuristic mapping to -15..+15 range
  if (typeof x === "number") return Math.max(-15, Math.min(15, Math.round(x / 5))); // scale down
  if (x === "low") return 5;
  if (x === "med" || x === "medium") return 10;
  if (x === "high") return 15;
  if (x === "soothe") return -5;
  if (x === "calm") return -10;
  return 0;
}

function mapTrustHint(score: any): TrustHint {
  const n = typeof score === "number" ? score : 50;
  if (n >= 15) return "too_trusting";      // High positive trust scores = too trusting
  if (n <= -15) return "too_skeptical";   // Negative trust scores = too skeptical
  return "appropriate";
}

function mapScamType(description: string, context: string): string {
  const text = (description + " " + context).toLowerCase();
  if (text.includes("romance") || text.includes("dating")) return "romance";
  if (text.includes("tech") || text.includes("support") || text.includes("microsoft")) return "tech_support";
  if (text.includes("prize") || text.includes("lottery") || text.includes("winner")) return "prize";
  if (text.includes("phish") || text.includes("email") || text.includes("link")) return "phishing";
  if (text.includes("job") || text.includes("employment")) return "job";
  if (text.includes("crypto") || text.includes("bitcoin")) return "crypto";
  if (text.includes("marketplace") || text.includes("buy") || text.includes("sell")) return "marketplace";
  if (text.includes("ceo") || text.includes("authority") || text.includes("official")) return "authority";
  return "phishing"; // default
}

function inferDifficulty(messageCount: number, choiceCount: number): "easy" | "medium" | "hard" {
  if (messageCount <= 4 && choiceCount <= 6) return "easy";
  if (messageCount <= 8 && choiceCount <= 12) return "medium";
  return "hard";
}

function convertLegacyScenario(legacyScenario: any): Scenario {
  const steps: Step[] = [];
  const stepIdMap = new Map<string, string>(); // legacy ID -> step ID

  // Extract messages object or array
  const messages = legacyScenario.messages?.start ?
    Object.values(legacyScenario.messages) :
    (Array.isArray(legacyScenario.messages) ? legacyScenario.messages : []);

  let stepIndex = 1;
  let totalChoices = 0;

  // First pass: create steps and map IDs
  for (const message of messages) {
    if (!message || typeof message !== 'object') continue;

    const stepId = `s${stepIndex++}`;
    const legacyId = message.id || message.messageId || stepId;
    stepIdMap.set(String(legacyId), stepId);

    const choices: Choice[] = [];
    if (Array.isArray(message.choices)) {
      totalChoices += message.choices.length;
      for (const choice of message.choices) {
        choices.push({
          id: choice.id || `c${choices.length + 1}`,
          label: choice.text || choice.label || "Continue",
          pressureDelta: mapPressure(choice.suspicionIncrease || choice.resistanceIncrease || choice.pressureDelta),
          trustHint: mapTrustHint(choice.trustScore || choice.trustHint),
          nextStepId: String(choice.nextMessageId || choice.nextStepId || ""),
          flags: choice.flags || []
        });
      }
    }

    const step: Step = {
      id: stepId,
      actor: message.isFromScammer === false ? "ally" :
             (message.from === "System" || message.from === "system") ? "system" : "scammer",
      text: message.text || message.content || "",
      ...(choices.length > 0 ? { choices } : {}),
      ...(message.nextMessageId ? { next: String(message.nextMessageId) } : {}),
      ...((!choices.length && !message.nextMessageId) ? { terminal: true } : {})
    };

    steps.push(step);
  }

  // Second pass: resolve next/nextStepId references
  for (const step of steps) {
    if (step.next) {
      step.next = stepIdMap.get(step.next) || step.next;
    }
    if (step.choices) {
      for (const choice of step.choices) {
        choice.nextStepId = stepIdMap.get(choice.nextStepId) || choice.nextStepId;
      }
    }
  }

  // Third pass: mark unreferenced steps as terminal
  const referencedSteps = new Set<string>();
  for (const step of steps) {
    if (step.next) referencedSteps.add(step.next);
    if (step.choices) {
      for (const choice of step.choices) {
        referencedSteps.add(choice.nextStepId);
      }
    }
  }

  for (const step of steps) {
    if (!step.choices && !step.next && !referencedSteps.has(step.id)) {
      step.terminal = true;
    }
  }

  const scenario: Scenario = {
    id: legacyScenario.id || "converted_scenario",
    title: legacyScenario.title || "Converted Scenario",
    difficulty: inferDifficulty(messages.length, totalChoices),
    meta: {
      scamType: mapScamType(legacyScenario.description || "", legacyScenario.context || ""),
      locale: "en-US",
      a11yHints: legacyScenario.redFlags || []
    },
    steps,
    entryStepId: steps[0]?.id || "s1",
    debrief: {
      redFlagPrimary: legacyScenario.redFlags?.[0] ||
                     legacyScenario.explanation ||
                     "Urgency tactics and requests for personal information",
      redFlagSecondary: legacyScenario.redFlags?.slice(1) || [],
      teachingPoints: [
        legacyScenario.explanation || "This scenario demonstrates common manipulation tactics",
        "Always verify requests through official channels",
        "Be suspicious of urgent deadlines and pressure tactics"
      ].slice(0, 4),
      targetTrustRange: [40, 60] as [number, number]
    }
  };

  return scenario;
}

function convertLegacyBundle() {
  const SRC = "assets/enhanced_dynamic_scenarios.json";
  const OUTDIR = "assets/scenarios";

  if (!existsSync(SRC)) {
    console.log(`Legacy bundle ${SRC} not found, skipping conversion`);
    return;
  }

  try {
    const raw = readFileSync(SRC, "utf8");
    const legacyData = JSON.parse(raw);

    // Handle both array format and scenarios object
    const scenarios = Array.isArray(legacyData) ? legacyData :
                     legacyData.scenarios ? legacyData.scenarios : [legacyData];

    for (const legacyScenario of scenarios) {
      if (!legacyScenario || typeof legacyScenario !== 'object') continue;

      try {
        const unified = convertLegacyScenario(legacyScenario);
        const outputPath = join(OUTDIR, `${unified.id}.json`);

        // Check if already converted (idempotent)
        if (existsSync(outputPath)) {
          const existing = JSON.parse(readFileSync(outputPath, "utf8"));
          if (existing.meta && existing.debrief && existing.steps?.[0]?.actor) {
            console.log(`Skipping ${unified.id} - already converted`);
            continue;
          }
        }

        writeFileSync(outputPath, JSON.stringify(unified, null, 2));
        console.log(`Converted ${unified.id} -> ${outputPath}`);

      } catch (error) {
        console.error(`Failed to convert scenario ${legacyScenario.id || 'unknown'}:`, error);
      }
    }
  } catch (error) {
    console.error(`Failed to read legacy bundle ${SRC}:`, error);
  }
}

function convertIndividualFiles() {
  const dirs = ["assets", "lib/data"];
  const patterns = [/scenarios?\.json$/, /\.scenario\.json$/];

  for (const dir of dirs) {
    if (!existsSync(dir)) continue;

    for (const file of readdirSync(dir)) {
      if (!patterns.some(p => p.test(file))) continue;

      const filePath = join(dir, file);
      try {
        const raw = readFileSync(filePath, "utf8");
        const data = JSON.parse(raw);

        // Skip if already unified format
        if (data.meta && data.debrief && data.steps?.[0]?.actor) continue;

        // Convert legacy format
        if (data.messages || Array.isArray(data)) {
          const scenarios = Array.isArray(data) ? data : [data];
          for (const scenario of scenarios) {
            const unified = convertLegacyScenario(scenario);
            const outputPath = join("assets/scenarios", `${unified.id}.json`);
            writeFileSync(outputPath, JSON.stringify(unified, null, 2));
            console.log(`Converted individual file ${filePath} -> ${outputPath}`);
          }
        }
      } catch (error) {
        console.error(`Failed to process ${filePath}:`, error);
      }
    }
  }
}

if (require.main === module) {
  console.log("Converting legacy scenarios to unified format...");
  convertLegacyBundle();
  convertIndividualFiles();
  console.log("Conversion complete!");
}

export { convertLegacyScenario, mapPressure, mapTrustHint };