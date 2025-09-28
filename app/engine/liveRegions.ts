// Live Regions for Screen Reader Accessibility - PRD-02 v2.1
// Manages debounced announcements for trust/pressure changes

let lastAnnounce = 0;
const ANNOUNCE_DEBOUNCE_MS = 700; // PRD requirement: ≥700ms debounce

export function announce(element: HTMLElement, message: string, priority: 'polite' | 'assertive' = 'polite') {
  const now = Date.now();
  if (now - lastAnnounce < ANNOUNCE_DEBOUNCE_MS) {
    return false; // Skipped due to debounce
  }

  lastAnnounce = now;

  // Clear and set content to ensure screen reader notices change
  element.textContent = '';

  // Use timeout to ensure content is cleared before setting new content
  setTimeout(() => {
    element.textContent = message;
    element.setAttribute('aria-live', priority);
    element.setAttribute('aria-atomic', 'true');
    element.setAttribute('aria-relevant', 'text');
  }, 10);

  return true; // Successfully announced
}

export function createLiveRegion(id: string, className?: string): HTMLElement {
  // Remove existing element if it exists
  const existing = document.getElementById(id);
  if (existing) {
    existing.remove();
  }

  const element = document.createElement('div');
  element.id = id;
  element.setAttribute('aria-live', 'polite');
  element.setAttribute('aria-atomic', 'true');
  element.setAttribute('aria-relevant', 'text');
  element.className = `sr-only ${className || ''}`.trim();

  // Screen reader only styles
  element.style.cssText = `
    position: absolute !important;
    width: 1px !important;
    height: 1px !important;
    padding: 0 !important;
    margin: -1px !important;
    overflow: hidden !important;
    clip: rect(0, 0, 0, 0) !important;
    white-space: nowrap !important;
    border: 0 !important;
  `;

  document.body.appendChild(element);
  return element;
}

// Global live regions for trust and pressure announcements
let trustRegion: HTMLElement | null = null;
let pressureRegion: HTMLElement | null = null;
let generalRegion: HTMLElement | null = null;

export function initializeLiveRegions() {
  trustRegion = createLiveRegion('trust-live-region', 'trust-announcements');
  pressureRegion = createLiveRegion('pressure-live-region', 'pressure-announcements');
  generalRegion = createLiveRegion('general-live-region', 'general-announcements');
}

export function announceTrustChange(trust: number, feedback: string, zone: string) {
  if (!trustRegion) {
    initializeLiveRegions();
  }

  // Only announce significant changes or zone transitions
  const message = `Trust: ${feedback}`;

  if (trustRegion) {
    announce(trustRegion, message);
  }
}

export function announcePressureChange(pressure: number, feedback: string, zone: string, delta: number) {
  if (!pressureRegion) {
    initializeLiveRegions();
  }

  // Only announce pressure changes ≥5 points or zone changes
  if (Math.abs(delta) >= 5 || zone === 'critical') {
    const priority = zone === 'critical' ? 'assertive' : 'polite';
    const message = `Pressure: ${feedback}`;

    if (pressureRegion) {
      announce(pressureRegion, message, priority);
    }
  }
}

export function announceGeneral(message: string, priority: 'polite' | 'assertive' = 'polite') {
  if (!generalRegion) {
    initializeLiveRegions();
  }

  if (generalRegion) {
    announce(generalRegion, message, priority);
  }
}

// Cleanup function for SPA navigation
export function cleanupLiveRegions() {
  if (trustRegion) {
    trustRegion.remove();
    trustRegion = null;
  }
  if (pressureRegion) {
    pressureRegion.remove();
    pressureRegion = null;
  }
  if (generalRegion) {
    generalRegion.remove();
    generalRegion = null;
  }
}

// Utility function to get existing live regions
export function getLiveRegions() {
  return {
    trust: trustRegion,
    pressure: pressureRegion,
    general: generalRegion
  };
}

// Auto-initialize on import in browser environment
if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  // Wait for DOM to be ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeLiveRegions);
  } else {
    initializeLiveRegions();
  }
}