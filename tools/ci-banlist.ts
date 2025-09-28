#!/usr/bin/env ts-node
// CI Banlist - Legacy Field Kill Switch
// Ensures no legacy fields remain in scenario files

import { readFileSync, readdirSync } from "fs";
import { join } from "path";

const LEGACY_FIELDS = /(suspicionIncrease|resistanceIncrease|trustScore|nextMessageId|messageId)\b/g;
const BANNED_PATTERNS = [
  /manipulationIntensity/g,  // Legacy field
  /isFromScammer/g,          // Legacy field
  /phase:/g,                 // Legacy field
  /tactics:\s*\[/g          // Legacy array format
];

function checkFile(filePath: string): string[] {
  const content = readFileSync(filePath, "utf8");
  const errors: string[] = [];

  // Check for legacy fields
  const legacyMatches = content.match(LEGACY_FIELDS);
  if (legacyMatches) {
    errors.push(`Legacy fields found: ${[...new Set(legacyMatches)].join(", ")}`);
  }

  // Check for banned patterns
  for (const pattern of BANNED_PATTERNS) {
    const matches = content.match(pattern);
    if (matches) {
      errors.push(`Banned pattern found: ${matches[0]}`);
    }
  }

  return errors;
}

function main() {
  const scenarioDir = "assets/scenarios";
  let totalFiles = 0;
  let errorFiles: string[] = [];
  const allErrors: { file: string; errors: string[] }[] = [];

  try {
    const files = readdirSync(scenarioDir);

    for (const file of files) {
      if (!file.endsWith(".json")) continue;

      totalFiles++;
      const filePath = join(scenarioDir, file);

      try {
        const errors = checkFile(filePath);
        if (errors.length > 0) {
          errorFiles.push(file);
          allErrors.push({ file, errors });
        }
      } catch (error) {
        errorFiles.push(file);
        allErrors.push({ file, errors: [`Failed to read file: ${error}`] });
      }
    }

    // Report results
    if (allErrors.length === 0) {
      console.log(`✅ All ${totalFiles} scenario files passed legacy field check`);
      process.exit(0);
    } else {
      console.error(`❌ ${allErrors.length}/${totalFiles} files contain legacy fields:`);
      console.error("");

      for (const { file, errors } of allErrors) {
        console.error(`${file}:`);
        for (const error of errors) {
          console.error(`  - ${error}`);
        }
        console.error("");
      }

      console.error("Run 'npm run convert:legacy' to migrate legacy scenarios");
      process.exit(1);
    }

  } catch (error) {
    console.error(`Failed to scan scenario directory: ${error}`);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { checkFile, LEGACY_FIELDS, BANNED_PATTERNS };