#!/usr/bin/env ts-node
// Accessibility Smoke Tests - PRD-02 v2.1
// Validates accessibility requirements for UI components

import { readFileSync, readdirSync } from "fs";
import { join } from "path";

interface A11yCheck {
  file: string;
  passed: boolean;
  errors: string[];
  warnings: string[];
}

interface A11yReport {
  totalFiles: number;
  passedFiles: number;
  checks: A11yCheck[];
  summary: {
    ariaLabels: number;
    liveRegions: number;
    semanticHeadings: number;
    keyboardNav: number;
    colorIndependence: number;
    focusManagement: number;
  };
}

class AccessibilityValidator {
  private uiDir = "app/ui";
  private engineDir = "app/engine";

  async runSmokeTests(): Promise<A11yReport> {
    const checks: A11yCheck[] = [];
    const summary = {
      ariaLabels: 0,
      liveRegions: 0,
      semanticHeadings: 0,
      keyboardNav: 0,
      colorIndependence: 0,
      focusManagement: 0
    };

    // Check UI components
    const uiFiles = this.getTypeScriptFiles(this.uiDir);
    for (const file of uiFiles) {
      const check = this.checkUIComponent(file);
      checks.push(check);
      this.updateSummary(check, summary);
    }

    // Check engine files for accessibility features
    const engineFiles = this.getTypeScriptFiles(this.engineDir);
    for (const file of engineFiles) {
      const check = this.checkEngineFile(file);
      checks.push(check);
      this.updateSummary(check, summary);
    }

    const passedFiles = checks.filter(c => c.passed).length;

    return {
      totalFiles: checks.length,
      passedFiles,
      checks,
      summary
    };
  }

  private getTypeScriptFiles(dir: string): string[] {
    try {
      return readdirSync(dir)
        .filter(file => file.endsWith('.tsx') || file.endsWith('.ts'))
        .map(file => join(dir, file));
    } catch (error) {
      console.warn(`Directory ${dir} not found, skipping`);
      return [];
    }
  }

  private checkUIComponent(filePath: string): A11yCheck {
    const fileName = filePath.split('/').pop() || filePath;
    const errors: string[] = [];
    const warnings: string[] = [];

    try {
      const content = readFileSync(filePath, 'utf8');

      // ARIA labels and roles
      this.checkAriaLabels(content, errors, warnings);

      // Semantic HTML and headings
      this.checkSemanticHTML(content, errors, warnings);

      // Keyboard navigation
      this.checkKeyboardNav(content, errors, warnings);

      // Color independence
      this.checkColorIndependence(content, errors, warnings);

      // Focus management
      this.checkFocusManagement(content, errors, warnings);

      // Live regions
      this.checkLiveRegions(content, errors, warnings);

      // Screen reader support
      this.checkScreenReaderSupport(content, errors, warnings);

    } catch (error) {
      errors.push(`Failed to read file: ${error}`);
    }

    return {
      file: fileName,
      passed: errors.length === 0,
      errors,
      warnings
    };
  }

  private checkEngineFile(filePath: string): A11yCheck {
    const fileName = filePath.split('/').pop() || filePath;
    const errors: string[] = [];
    const warnings: string[] = [];

    try {
      const content = readFileSync(filePath, 'utf8');

      // Live regions implementation
      if (fileName.includes('liveRegions')) {
        this.checkLiveRegionsImplementation(content, errors, warnings);
      }

      // Haptic feedback accessibility
      if (fileName.includes('haptics')) {
        this.checkHapticsAccessibility(content, errors, warnings);
      }

      // Feature flags for accessibility
      if (fileName.includes('featureFlags')) {
        this.checkAccessibilityFlags(content, errors, warnings);
      }

    } catch (error) {
      errors.push(`Failed to read file: ${error}`);
    }

    return {
      file: fileName,
      passed: errors.length === 0,
      errors,
      warnings
    };
  }

  private checkAriaLabels(content: string, errors: string[], warnings: string[]): void {
    // Check for aria-label, aria-labelledby, role attributes
    const hasAriaLabel = /aria-label(ledby)?=/.test(content);
    const hasRole = /role=/.test(content);
    const hasInteractive = /(button|input|select|textarea)/.test(content);

    if (hasInteractive && !hasAriaLabel && !hasRole) {
      warnings.push("Interactive elements should have ARIA labels or roles");
    }

    // Check for proper ARIA values
    const ariaLiveRegex = /aria-live=["']?(polite|assertive|off)["']?/g;
    const badAriaLive = /aria-live=["']?(?!polite|assertive|off)/.test(content);
    if (badAriaLive) {
      errors.push("Invalid aria-live value (must be 'polite', 'assertive', or 'off')");
    }

    // Check for aria-atomic and aria-relevant on live regions
    if (/aria-live/.test(content)) {
      if (!/aria-atomic/.test(content)) {
        warnings.push("Live regions should include aria-atomic attribute");
      }
      if (!/aria-relevant/.test(content)) {
        warnings.push("Live regions should include aria-relevant attribute");
      }
    }
  }

  private checkSemanticHTML(content: string, errors: string[], warnings: string[]): void {
    // Check for heading hierarchy
    const hasHeadings = /<h[1-6]/.test(content);
    const hasSemanticElements = /(header|nav|main|section|article|aside|footer)/.test(content);

    if (content.includes('className') && !hasSemanticElements) {
      warnings.push("Consider using semantic HTML elements (header, nav, main, section, etc.)");
    }

    // Check for proper heading structure (red flags should be h2)
    if (content.includes('red flag') || content.includes('Red Flag')) {
      if (!/<h2/.test(content)) {
        errors.push("Red flag sections should use <h2> for screen reader navigation");
      }
    }

    // Check for list semantics
    if (content.includes('teachingPoints') || content.includes('redFlagSecondary')) {
      if (!/<ul|<ol|<li/.test(content)) {
        warnings.push("Lists of teaching points should use proper list markup (<ul>, <li>)");
      }
    }
  }

  private checkKeyboardNav(content: string, errors: string[], warnings: string[]): void {
    // Check for keyboard event handlers
    const hasKeyboardEvents = /(onKeyDown|onKeyUp|onKeyPress)/.test(content);
    const hasClickHandler = /onClick/.test(content);

    if (hasClickHandler && !hasKeyboardEvents) {
      warnings.push("Interactive elements with onClick should also handle keyboard events");
    }

    // Check for tabIndex usage
    const hasTabIndex = /tabIndex/.test(content);
    const hasNegativeTabIndex = /tabIndex=["']?-1["']?/.test(content);

    if (hasNegativeTabIndex && !content.includes('sr-only')) {
      warnings.push("Negative tabIndex should only be used for screen reader content");
    }

    // Check for focus management
    const hasFocusManagement = /(focus\(\)|useRef|focusRef)/.test(content);
    if (content.includes('modal') || content.includes('dialog')) {
      if (!hasFocusManagement) {
        errors.push("Modal/dialog components must manage focus properly");
      }
    }
  }

  private checkColorIndependence(content: string, errors: string[], warnings: string[]): void {
    // Check for color-only information
    const colorOnlyPatterns = [
      /className=["'][^"']*(?:red|green|blue|yellow)-\d+[^"']*["']/,
      /bg-(red|green|blue|yellow)-/
    ];

    let hasColorOnly = false;
    for (const pattern of colorOnlyPatterns) {
      if (pattern.test(content)) {
        hasColorOnly = true;
        break;
      }
    }

    if (hasColorOnly) {
      // Check for alternative indicators (icons, text, patterns)
      const hasAlternatives = /(icon|Icon|✅|❌|⚠️|🔴|🟡|🟢|text-|aria-label)/.test(content);
      if (!hasAlternatives) {
        errors.push("Color-based information must include non-color alternatives (icons, text, patterns)");
      }
    }

    // Check for high contrast support
    if (/bg-/.test(content) || /text-/.test(content)) {
      if (!/(shouldUseHighContrast|highContrast)/.test(content)) {
        warnings.push("Components with color should support high contrast mode");
      }
    }
  }

  private checkFocusManagement(content: string, errors: string[], warnings: string[]): void {
    // Check for visible focus indicators
    const hasFocusStyles = /(focus:|focus-|focus:outline|focus:ring)/.test(content);
    const hasInteractive = /(button|input|select|textarea|onClick)/.test(content);

    if (hasInteractive && !hasFocusStyles) {
      errors.push("Interactive elements must have visible focus indicators");
    }

    // Check for focus trap in modals
    if (content.includes('modal') || content.includes('dialog')) {
      if (!/focus/.test(content)) {
        errors.push("Modal components must implement focus management");
      }
    }
  }

  private checkLiveRegions(content: string, errors: string[], warnings: string[]): void {
    // Check for live region usage
    const hasLiveRegion = /aria-live/.test(content);
    const isDynamic = /(trust|pressure|feedback)/.test(content);

    if (isDynamic && !hasLiveRegion) {
      warnings.push("Dynamic content should use live regions for screen reader announcements");
    }

    // Check for proper live region implementation
    if (hasLiveRegion) {
      if (!/aria-atomic/.test(content)) {
        warnings.push("Live regions should include aria-atomic='true'");
      }
    }
  }

  private checkScreenReaderSupport(content: string, errors: string[], warnings: string[]): void {
    // Check for sr-only content
    const hasSROnly = /(sr-only|screen.*reader)/.test(content);
    const hasComplexUI = /(meter|progress|chart|graph)/.test(content);

    if (hasComplexUI && !hasSROnly) {
      warnings.push("Complex UI components should include screen reader only descriptions");
    }

    // Check for proper meter/progress labeling
    if (/role=["']?meter["']?/.test(content)) {
      if (!/aria-labelledby/.test(content) && !/aria-label/.test(content)) {
        errors.push("Meter elements must have accessible labels");
      }
    }
  }

  private checkLiveRegionsImplementation(content: string, errors: string[], warnings: string[]): void {
    // Check for debounce implementation
    if (!/(debounce|DEBOUNCE)/.test(content)) {
      errors.push("Live regions must implement debouncing to prevent announcement spam");
    }

    // Check for proper announcement timing
    if (!/(700|ANNOUNCE_DEBOUNCE)/.test(content)) {
      warnings.push("Live region debounce should be ≥700ms as per PRD requirements");
    }

    // Check for cleanup
    if (!/cleanup|remove/.test(content)) {
      warnings.push("Live regions should have cleanup functionality for SPA navigation");
    }
  }

  private checkHapticsAccessibility(content: string, errors: string[], warnings: string[]): void {
    // Check for system settings respect
    if (!/(system|settings|navigator)/.test(content)) {
      errors.push("Haptic feedback must respect system accessibility settings");
    }

    // Check for debouncing
    if (!/(debounce|limit)/.test(content)) {
      warnings.push("Haptic feedback should be debounced to prevent overwhelming users");
    }

    // Check for reduced motion support
    if (!/reducedMotion/.test(content)) {
      warnings.push("Haptic feedback should respect prefers-reduced-motion settings");
    }
  }

  private checkAccessibilityFlags(content: string, errors: string[], warnings: string[]): void {
    // Check for required accessibility flags
    const requiredFlags = [
      'screenReaderOptimized',
      'highContrastMode',
      'reducedMotion'
    ];

    for (const flag of requiredFlags) {
      if (!content.includes(flag)) {
        warnings.push(`Missing accessibility feature flag: ${flag}`);
      }
    }

    // Check for auto-detection
    if (!/(matchMedia|prefers-)/) {
      warnings.push("Should auto-detect system accessibility preferences");
    }
  }

  private updateSummary(check: A11yCheck, summary: any): void {
    if (check.errors.length === 0) {
      if (check.file.includes('aria') || check.errors.some(e => e.includes('aria'))) {
        summary.ariaLabels++;
      }
      if (check.file.includes('liveRegions') || check.errors.some(e => e.includes('live'))) {
        summary.liveRegions++;
      }
      if (check.errors.some(e => e.includes('heading') || e.includes('h1') || e.includes('h2'))) {
        summary.semanticHeadings++;
      }
      if (check.errors.some(e => e.includes('keyboard') || e.includes('focus'))) {
        summary.keyboardNav++;
      }
      if (check.errors.some(e => e.includes('color') || e.includes('contrast'))) {
        summary.colorIndependence++;
      }
      if (check.errors.some(e => e.includes('focus') || e.includes('tabIndex'))) {
        summary.focusManagement++;
      }
    }
  }
}

async function main() {
  console.log("🔍 Running accessibility smoke tests...\n");

  const validator = new AccessibilityValidator();
  const report = await validator.runSmokeTests();

  // Print summary
  console.log("📋 Accessibility Test Summary");
  console.log("=".repeat(35));
  console.log(`Total files checked: ${report.totalFiles}`);
  console.log(`Files passed: ${report.passedFiles}`);
  console.log(`Pass rate: ${((report.passedFiles / report.totalFiles) * 100).toFixed(1)}%`);

  // Print detailed results
  const failed = report.checks.filter(c => !c.passed);
  if (failed.length > 0) {
    console.log("\n❌ Failed Files:");
    for (const check of failed) {
      console.log(`\n📄 ${check.file}`);
      for (const error of check.errors) {
        console.log(`  ❌ ${error}`);
      }
      for (const warning of check.warnings) {
        console.log(`  ⚠️  ${warning}`);
      }
    }
  }

  // Print warnings for passed files
  const passedWithWarnings = report.checks.filter(c => c.passed && c.warnings.length > 0);
  if (passedWithWarnings.length > 0) {
    console.log("\n⚠️  Warnings:");
    for (const check of passedWithWarnings) {
      console.log(`\n📄 ${check.file}`);
      for (const warning of check.warnings) {
        console.log(`  ⚠️  ${warning}`);
      }
    }
  }

  // Print accessibility feature summary
  console.log("\n🎯 Accessibility Features Found:");
  console.log(`  ARIA labels: ${report.summary.ariaLabels} files`);
  console.log(`  Live regions: ${report.summary.liveRegions} files`);
  console.log(`  Semantic headings: ${report.summary.semanticHeadings} files`);
  console.log(`  Keyboard navigation: ${report.summary.keyboardNav} files`);
  console.log(`  Color independence: ${report.summary.colorIndependence} files`);
  console.log(`  Focus management: ${report.summary.focusManagement} files`);

  // Exit with appropriate code
  const requiredPassRate = 0.8; // 80% minimum for smoke test
  const actualPassRate = report.passedFiles / report.totalFiles;

  if (actualPassRate >= requiredPassRate && report.totalFiles > 0) {
    console.log(`\n✅ Accessibility smoke tests passed (${(actualPassRate * 100).toFixed(1)}% >= 80%)`);
    process.exit(0);
  } else {
    console.error(`\n❌ Accessibility smoke tests failed (${(actualPassRate * 100).toFixed(1)}% < 80%)`);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { AccessibilityValidator, A11yCheck, A11yReport };