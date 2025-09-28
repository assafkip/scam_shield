#!/usr/bin/env ts-node
// Scenario Validator - PRD-02 v2.1
// Validates schema compliance, path completion, and reliability requirements

import Ajv from "ajv";
import { readFileSync, readdirSync } from "fs";
import { join } from "path";
import schema from "../schema/unified.schema.json";
import { validateScenario } from "./dfs";
import type { Scenario } from "../schema/unified.types";

interface ValidationResult {
  file: string;
  valid: boolean;
  errors: string[];
  warnings: string[];
  pathInfo?: {
    reachableSteps: number;
    terminalSteps: number;
    orphanedSteps: number;
    hasDebrief: boolean;
  };
}

class ScenarioValidator {
  private ajv = new Ajv({ allErrors: true });
  private validateSchema = this.ajv.compile(schema as any);

  validateFile(filePath: string): ValidationResult {
    const fileName = filePath.split("/").pop() || filePath;
    const result: ValidationResult = {
      file: fileName,
      valid: false,
      errors: [],
      warnings: []
    };

    try {
      // Read and parse JSON
      const content = readFileSync(filePath, "utf8");
      let data: any;

      try {
        data = JSON.parse(content);
      } catch (parseError) {
        result.errors.push(`Invalid JSON: ${parseError}`);
        return result;
      }

      // Schema validation
      if (!this.validateSchema(data)) {
        const schemaErrors = this.ajv.errorsText(this.validateSchema.errors);
        result.errors.push(`Schema validation failed: ${schemaErrors}`);
        return result;
      }

      const scenario: Scenario = data;

      // Debrief validation
      if (!scenario.debrief?.redFlagPrimary) {
        result.errors.push("Missing debrief.redFlagPrimary");
      }

      if (!scenario.debrief?.teachingPoints || scenario.debrief.teachingPoints.length < 2) {
        result.errors.push("debrief.teachingPoints must have 2-4 items");
      }

      if (!scenario.debrief?.targetTrustRange || scenario.debrief.targetTrustRange.length !== 2) {
        result.errors.push("debrief.targetTrustRange must be [min, max] tuple");
      }

      // Path and logic validation
      try {
        const pathValidation = validateScenario(scenario);
        result.pathInfo = {
          reachableSteps: pathValidation.reachableSteps.length,
          terminalSteps: pathValidation.terminalSteps.length,
          orphanedSteps: pathValidation.orphanedSteps.length,
          hasDebrief: pathValidation.hasDebrief
        };

        if (!pathValidation.hasDebrief) {
          result.errors.push("No terminal steps found - scenario must end in debrief");
        }

        if (pathValidation.orphanedSteps.length > 0) {
          result.warnings.push(`Orphaned steps: ${pathValidation.orphanedSteps.join(", ")}`);
        }

      } catch (validationError) {
        result.errors.push(`Path validation failed: ${validationError}`);
      }

      // Entry step validation
      const entryExists = scenario.steps.some(step => step.id === scenario.entryStepId);
      if (!entryExists) {
        result.errors.push(`Entry step "${scenario.entryStepId}" not found in steps`);
      }

      // 30-second demo validation for easy scenarios
      if (scenario.difficulty === "easy") {
        const totalChoices = scenario.steps.reduce((sum, step) =>
          sum + (step.choices?.length || 0), 0);
        if (totalChoices > 6) {
          result.warnings.push(`Easy scenario has ${totalChoices} total choices - may exceed 30-second target`);
        }
      }

      // Success if no errors
      result.valid = result.errors.length === 0;

    } catch (error) {
      result.errors.push(`Validation error: ${error}`);
    }

    return result;
  }

  validateDirectory(dirPath: string): {
    total: number;
    passed: number;
    results: ValidationResult[];
    reliabilityScore: number;
  } {
    const results: ValidationResult[] = [];
    let passed = 0;

    try {
      const files = readdirSync(dirPath)
        .filter(file => file.endsWith(".json"))
        .sort();

      for (const file of files) {
        const filePath = join(dirPath, file);
        const result = this.validateFile(filePath);
        results.push(result);

        if (result.valid) {
          passed++;
        }
      }

    } catch (error) {
      console.error(`Failed to scan directory ${dirPath}: ${error}`);
    }

    const total = results.length;
    const reliabilityScore = total > 0 ? (passed / total) * 100 : 0;

    return { total, passed, results, reliabilityScore };
  }
}

function formatValidationReport(results: ValidationResult[]): string {
  const lines: string[] = [];
  lines.push("# Scenario Validation Report");
  lines.push("");

  const passed = results.filter(r => r.valid);
  const failed = results.filter(r => !r.valid);

  lines.push(`**Summary**: ${passed.length}/${results.length} scenarios passed (${((passed.length / results.length) * 100).toFixed(1)}%)`);
  lines.push("");

  if (failed.length > 0) {
    lines.push("## ❌ Failed Scenarios");
    lines.push("");
    for (const result of failed) {
      lines.push(`### ${result.file}`);
      for (const error of result.errors) {
        lines.push(`- ❌ ${error}`);
      }
      for (const warning of result.warnings) {
        lines.push(`- ⚠️  ${warning}`);
      }
      lines.push("");
    }
  }

  if (passed.length > 0) {
    lines.push("## ✅ Passed Scenarios");
    lines.push("");
    for (const result of passed) {
      const pathInfo = result.pathInfo;
      const info = pathInfo ?
        `(${pathInfo.reachableSteps} steps, ${pathInfo.terminalSteps} endings)` : "";
      lines.push(`- **${result.file}** ${info}`);
      if (result.warnings.length > 0) {
        for (const warning of result.warnings) {
          lines.push(`  - ⚠️  ${warning}`);
        }
      }
    }
  }

  return lines.join("\n");
}

function main() {
  const scenarioDir = "assets/scenarios";
  const validator = new ScenarioValidator();
  const { total, passed, results, reliabilityScore } = validator.validateDirectory(scenarioDir);

  console.log(formatValidationReport(results));
  console.log("");

  // PRD-02 v2.1 requires 95% reliability
  const required = 95.0;
  if (reliabilityScore >= required) {
    console.log(`✅ Reliability ${reliabilityScore.toFixed(1)}% >= ${required}% required`);
    process.exit(0);
  } else {
    console.error(`❌ Reliability ${reliabilityScore.toFixed(1)}% < ${required}% required`);
    console.error("");
    console.error("Failing scenarios:");
    for (const result of results.filter(r => !r.valid)) {
      console.error(`  - ${result.file}: ${result.errors.join("; ")}`);
    }
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { ScenarioValidator, formatValidationReport };