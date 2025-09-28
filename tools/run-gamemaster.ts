#!/usr/bin/env ts-node
// Game Master Simulation - PRD-02 v2.1
// Simulates scenario playthrough to test completion and reliability

import { readFileSync, readdirSync } from "fs";
import { join } from "path";
import type { Scenario, Step, Choice, ConversationState, TrustPressureTrace } from "../schema/unified.types";
import { applyChoice, createTrustPressureTrace } from "../app/engine/trustPressure";

interface SimulationResult {
  scenarioId: string;
  success: boolean;
  error?: string;
  paths: PathResult[];
  totalPaths: number;
  completedPaths: number;
  averageSteps: number;
  executionTime: number;
}

interface PathResult {
  pathId: string;
  steps: string[];
  choices: string[];
  finalTrust: number;
  finalPressure: number;
  completedSuccessfully: boolean;
  error?: string;
}

class GameMasterSimulator {
  private maxStepsPerPath = 20;
  private maxPathsToTest = 50;

  async simulateScenario(scenario: Scenario): Promise<SimulationResult> {
    const startTime = Date.now();
    const paths: PathResult[] = [];

    try {
      // Generate all possible paths through the scenario
      const allPaths = this.generatePaths(scenario);
      const pathsToTest = allPaths.slice(0, this.maxPathsToTest);

      for (const path of pathsToTest) {
        const pathResult = await this.simulatePath(scenario, path);
        paths.push(pathResult);
      }

      const completedPaths = paths.filter(p => p.completedSuccessfully).length;
      const averageSteps = paths.length > 0 ?
        paths.reduce((sum, p) => sum + p.steps.length, 0) / paths.length : 0;

      return {
        scenarioId: scenario.id,
        success: completedPaths > 0,
        paths,
        totalPaths: allPaths.length,
        completedPaths,
        averageSteps,
        executionTime: Date.now() - startTime
      };

    } catch (error) {
      return {
        scenarioId: scenario.id,
        success: false,
        error: `Simulation failed: ${error}`,
        paths,
        totalPaths: 0,
        completedPaths: 0,
        averageSteps: 0,
        executionTime: Date.now() - startTime
      };
    }
  }

  private generatePaths(scenario: Scenario): string[][] {
    const paths: string[][] = [];
    const visited = new Set<string>();

    const stepMap = new Map<string, Step>();
    for (const step of scenario.steps) {
      stepMap.set(step.id, step);
    }

    const explorePath = (stepId: string, currentPath: string[], depth: number) => {
      if (depth > this.maxStepsPerPath) {
        return; // Prevent infinite loops
      }

      const pathKey = currentPath.join('-') + '-' + stepId;
      if (visited.has(pathKey)) {
        return;
      }
      visited.add(pathKey);

      const step = stepMap.get(stepId);
      if (!step) {
        return;
      }

      const newPath = [...currentPath, stepId];

      if (step.terminal || !step.choices?.length) {
        // Terminal step - complete path
        paths.push(newPath);
        return;
      }

      if (step.choices && step.choices.length > 0) {
        // Explore each choice
        for (const choice of step.choices) {
          explorePath(choice.nextStepId, newPath, depth + 1);
        }
      } else if (step.next) {
        // Single next step
        explorePath(step.next, newPath, depth + 1);
      }
    };

    explorePath(scenario.entryStepId, [], 0);
    return paths;
  }

  private async simulatePath(scenario: Scenario, stepIds: string[]): Promise<PathResult> {
    const pathId = stepIds.join('-');
    const choices: string[] = [];
    let state: ConversationState = {
      scenarioId: scenario.id,
      currentStepId: scenario.entryStepId,
      visitedSteps: [],
      trust: 50, // Start at neutral
      pressure: 0,
      choices: [],
      isCompleted: false,
      debriefReady: false
    };

    const traces: TrustPressureTrace[] = [];

    try {
      const stepMap = new Map<string, Step>();
      for (const step of scenario.steps) {
        stepMap.set(step.id, step);
      }

      for (let i = 0; i < stepIds.length - 1; i++) {
        const currentStepId = stepIds[i];
        const nextStepId = stepIds[i + 1];

        const currentStep = stepMap.get(currentStepId);
        if (!currentStep) {
          throw new Error(`Step not found: ${currentStepId}`);
        }

        if (currentStep.choices && currentStep.choices.length > 0) {
          // Find the choice that leads to the next step
          const choice = currentStep.choices.find(c => c.nextStepId === nextStepId);
          if (!choice) {
            throw new Error(`No choice leads from ${currentStepId} to ${nextStepId}`);
          }

          // Apply choice effects
          const beforeState = { trust: state.trust, pressure: state.pressure };
          const update = applyChoice(beforeState, {
            pressureDelta: choice.pressureDelta,
            trustHint: choice.trustHint
          });

          // Create trace
          const trace = createTrustPressureTrace(
            currentStepId,
            choice.id,
            beforeState,
            { trust: update.trust, pressure: update.pressure }
          );
          traces.push(trace);

          // Update state
          state = {
            ...state,
            currentStepId: nextStepId,
            visitedSteps: [...state.visitedSteps, currentStepId],
            trust: update.trust,
            pressure: update.pressure,
            choices: [...state.choices, { stepId: currentStepId, choiceId: choice.id }]
          };

          choices.push(choice.id);

        } else if (currentStep.next === nextStepId) {
          // Direct transition
          state = {
            ...state,
            currentStepId: nextStepId,
            visitedSteps: [...state.visitedSteps, currentStepId]
          };
        } else {
          throw new Error(`Cannot transition from ${currentStepId} to ${nextStepId}`);
        }
      }

      // Check if final step is terminal
      const finalStep = stepMap.get(stepIds[stepIds.length - 1]);
      const completedSuccessfully = finalStep?.terminal === true;

      if (completedSuccessfully) {
        state = { ...state, isCompleted: true, debriefReady: true };
      }

      return {
        pathId,
        steps: stepIds,
        choices,
        finalTrust: state.trust,
        finalPressure: state.pressure,
        completedSuccessfully
      };

    } catch (error) {
      return {
        pathId,
        steps: stepIds,
        choices,
        finalTrust: state.trust,
        finalPressure: state.pressure,
        completedSuccessfully: false,
        error: `Path simulation failed: ${error}`
      };
    }
  }
}

async function main() {
  const scenarioDir = "assets/scenarios";
  const simulator = new GameMasterSimulator();
  const results: SimulationResult[] = [];
  let totalScenarios = 0;
  let successfulScenarios = 0;

  try {
    const files = readdirSync(scenarioDir)
      .filter(file => file.endsWith(".json"))
      .sort();

    console.log(`🎮 Running Game Master simulation on ${files.length} scenarios...\n`);

    for (const file of files) {
      const filePath = join(scenarioDir, file);
      totalScenarios++;

      try {
        const content = readFileSync(filePath, "utf8");
        const scenario: Scenario = JSON.parse(content);

        console.log(`Testing ${scenario.id}...`);
        const result = await simulator.simulateScenario(scenario);
        results.push(result);

        if (result.success) {
          successfulScenarios++;
          console.log(`  ✅ Success: ${result.completedPaths}/${result.totalPaths} paths completed`);
        } else {
          console.log(`  ❌ Failed: ${result.error}`);
        }

      } catch (error) {
        const result: SimulationResult = {
          scenarioId: file.replace('.json', ''),
          success: false,
          error: `Failed to load scenario: ${error}`,
          paths: [],
          totalPaths: 0,
          completedPaths: 0,
          averageSteps: 0,
          executionTime: 0
        };
        results.push(result);
        console.log(`  ❌ Load failed: ${error}`);
      }
    }

    // Generate summary report
    console.log("\n📊 Game Master Simulation Summary");
    console.log("=".repeat(40));
    console.log(`Total scenarios: ${totalScenarios}`);
    console.log(`Successful scenarios: ${successfulScenarios}`);
    console.log(`Success rate: ${((successfulScenarios / totalScenarios) * 100).toFixed(1)}%`);

    const totalPaths = results.reduce((sum, r) => sum + r.completedPaths, 0);
    const avgSteps = results.length > 0 ?
      results.reduce((sum, r) => sum + r.averageSteps, 0) / results.length : 0;
    const totalTime = results.reduce((sum, r) => sum + r.executionTime, 0);

    console.log(`Total completed paths: ${totalPaths}`);
    console.log(`Average steps per path: ${avgSteps.toFixed(1)}`);
    console.log(`Total execution time: ${totalTime}ms`);

    // Show failed scenarios
    const failed = results.filter(r => !r.success);
    if (failed.length > 0) {
      console.log("\n❌ Failed Scenarios:");
      for (const failure of failed) {
        console.log(`  - ${failure.scenarioId}: ${failure.error}`);
      }
    }

    // Show scenarios with low path completion
    const lowCompletion = results.filter(r =>
      r.success && r.totalPaths > 0 && (r.completedPaths / r.totalPaths) < 0.8
    );
    if (lowCompletion.length > 0) {
      console.log("\n⚠️  Scenarios with <80% path completion:");
      for (const scenario of lowCompletion) {
        const rate = ((scenario.completedPaths / scenario.totalPaths) * 100).toFixed(1);
        console.log(`  - ${scenario.scenarioId}: ${rate}% (${scenario.completedPaths}/${scenario.totalPaths})`);
      }
    }

    // Exit with appropriate code
    const requiredSuccessRate = 0.95; // 95% as per PRD
    const actualSuccessRate = successfulScenarios / totalScenarios;

    if (actualSuccessRate >= requiredSuccessRate) {
      console.log(`\n✅ Game Master tests passed (${(actualSuccessRate * 100).toFixed(1)}% >= 95%)`);
      process.exit(0);
    } else {
      console.error(`\n❌ Game Master tests failed (${(actualSuccessRate * 100).toFixed(1)}% < 95%)`);
      process.exit(1);
    }

  } catch (error) {
    console.error(`Game Master simulation failed: ${error}`);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { GameMasterSimulator, SimulationResult, PathResult };