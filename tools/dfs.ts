// DFS Path Validation - PRD-02 v2.1
// Ensures all scenario paths lead to terminal steps for proper debrief

import type { Scenario, Step, PathValidation } from "../schema/unified.types";

export function dfsAllPathsToDebrief(scenario: Scenario): PathValidation {
  const stepIds = new Set(scenario.steps.map(step => step.id));
  const stepMap = new Map<string, Step>();

  // Build step lookup map
  for (const step of scenario.steps) {
    stepMap.set(step.id, step);
  }

  const reachableSteps = new Set<string>();
  const terminalSteps: string[] = [];
  const visitedPaths = new Set<string>();
  const errors: string[] = [];

  function validateStep(stepId: string): Step {
    if (!stepIds.has(stepId)) {
      throw new Error(`Missing step: ${stepId}`);
    }
    return stepMap.get(stepId)!;
  }

  function walkPath(stepId: string, path: string[] = []): void {
    // Prevent infinite loops
    const pathKey = path.join("->") + "->" + stepId;
    if (visitedPaths.has(pathKey)) {
      return;
    }
    visitedPaths.add(pathKey);

    if (path.length > 20) {
      throw new Error(`Path too deep (>20 steps), possible cycle: ${path.join(" -> ")} -> ${stepId}`);
    }

    try {
      const step = validateStep(stepId);
      reachableSteps.add(stepId);
      const newPath = [...path, stepId];

      if (step.choices && step.choices.length > 0) {
        // Step has choices - validate each path
        for (const choice of step.choices) {
          if (!choice.nextStepId) {
            throw new Error(`Choice ${choice.id} in step ${stepId} missing nextStepId`);
          }
          walkPath(choice.nextStepId, newPath);
        }
      } else if (step.next) {
        // Step has direct next - follow it
        walkPath(step.next, newPath);
      } else {
        // Terminal step - should be marked as such
        if (!step.terminal) {
          errors.push(`Step ${stepId} has no choices or next but not marked terminal`);
        }
        terminalSteps.push(stepId);
      }
    } catch (error) {
      errors.push(`Path validation error at ${stepId}: ${error}`);
    }
  }

  // Start DFS from entry point
  try {
    walkPath(scenario.entryStepId);
  } catch (error) {
    errors.push(`DFS failed from entry ${scenario.entryStepId}: ${error}`);
  }

  // Find orphaned steps (unreachable)
  const orphanedSteps = scenario.steps
    .map(step => step.id)
    .filter(id => !reachableSteps.has(id));

  // Validate terminal steps
  const hasDebrief = terminalSteps.length > 0;
  if (!hasDebrief) {
    errors.push("No terminal steps found - scenario has no clear ending");
  }

  if (errors.length > 0) {
    throw new Error(`Path validation failed:\n${errors.join("\n")}`);
  }

  return {
    reachableSteps: Array.from(reachableSteps),
    terminalSteps,
    orphanedSteps,
    hasDebrief
  };
}

export function validateChoiceTargets(scenario: Scenario): void {
  const stepIds = new Set(scenario.steps.map(step => step.id));
  const errors: string[] = [];

  for (const step of scenario.steps) {
    if (step.choices) {
      for (const choice of step.choices) {
        if (!stepIds.has(choice.nextStepId)) {
          errors.push(`Choice ${choice.id} in step ${step.id} references non-existent step: ${choice.nextStepId}`);
        }
      }
    }
    if (step.next && !stepIds.has(step.next)) {
      errors.push(`Step ${step.id} next reference points to non-existent step: ${step.next}`);
    }
  }

  if (errors.length > 0) {
    throw new Error(`Choice target validation failed:\n${errors.join("\n")}`);
  }
}

export function validateDifficultyConstraints(scenario: Scenario): void {
  const maxChoices = {
    easy: 3,
    medium: 5,
    hard: 7
  };

  const limit = maxChoices[scenario.difficulty];
  const errors: string[] = [];

  for (const step of scenario.steps) {
    const choiceCount = step.choices?.length || 0;
    if (choiceCount > limit) {
      errors.push(`Step ${step.id} has ${choiceCount} choices, exceeds ${scenario.difficulty} limit of ${limit}`);
    }
  }

  if (errors.length > 0) {
    throw new Error(`Difficulty constraint validation failed:\n${errors.join("\n")}`);
  }
}

export function validatePressureDeltas(scenario: Scenario): void {
  const errors: string[] = [];

  for (const step of scenario.steps) {
    if (step.choices) {
      for (const choice of step.choices) {
        if (choice.pressureDelta < -15 || choice.pressureDelta > 15) {
          errors.push(`Choice ${choice.id} in step ${step.id} has pressureDelta ${choice.pressureDelta}, must be -15 to +15`);
        }
      }
    }
  }

  if (errors.length > 0) {
    throw new Error(`Pressure delta validation failed:\n${errors.join("\n")}`);
  }
}

// Comprehensive scenario validation
export function validateScenario(scenario: Scenario): PathValidation {
  // Run all validations
  validateChoiceTargets(scenario);
  validateDifficultyConstraints(scenario);
  validatePressureDeltas(scenario);

  // Run DFS path validation
  return dfsAllPathsToDebrief(scenario);
}