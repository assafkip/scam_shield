// Trust Bar Component - PRD-02 v2.1
// Shows trust level with target range visualization and accessibility

import React, { useEffect, useRef } from 'react';
import { TARGET_RANGE } from '../engine/trustPressure';
import { announceTrustChange } from '../engine/liveRegions';
import { shouldUseHighContrast, shouldReduceMotion } from '../engine/featureFlags';

interface TrustBarProps {
  value: number;
  previousValue?: number;
  feedback: string;
  zone: 'too_low' | 'optimal' | 'too_high';
  className?: string;
  showNumeric?: boolean;
}

export function TrustBar({
  value,
  previousValue = value,
  feedback,
  zone,
  className = '',
  showNumeric = true
}: TrustBarProps) {
  const [targetMin, targetMax] = TARGET_RANGE;
  const barRef = useRef<HTMLDivElement>(null);
  const hasChanged = Math.abs(value - previousValue) >= 2;

  // Announce changes for screen readers
  useEffect(() => {
    if (hasChanged) {
      announceTrustChange(value, feedback, zone);
    }
  }, [value, feedback, zone, hasChanged]);

  // Color classes based on zone and high contrast preference
  const getColorClasses = () => {
    const highContrast = shouldUseHighContrast();
    const base = 'transition-all duration-300';

    if (highContrast) {
      switch (zone) {
        case 'too_high': return `${base} bg-black text-white border-2 border-black`;
        case 'too_low': return `${base} bg-gray-800 text-white border-2 border-gray-800`;
        case 'optimal': return `${base} bg-white text-black border-2 border-black`;
      }
    }

    switch (zone) {
      case 'too_high': return `${base} bg-red-500 text-white`;
      case 'too_low': return `${base} bg-blue-500 text-white`;
      case 'optimal': return `${base} bg-green-500 text-white`;
    }
  };

  const getZoneText = () => {
    switch (zone) {
      case 'too_high': return 'Too High';
      case 'too_low': return 'Too Low';
      case 'optimal': return 'On Target';
    }
  };

  const reducedMotion = shouldReduceMotion();

  return (
    <div className={`trust-bar ${className}`} role="meter" aria-labelledby="trust-label">
      {/* Label */}
      <div id="trust-label" className="text-sm font-medium mb-2 flex justify-between items-center">
        <span>Trust Level</span>
        {showNumeric && (
          <span className="text-sm">
            {Math.round(value)}% ({getZoneText()})
          </span>
        )}
      </div>

      {/* Target range indicator */}
      <div className="relative h-2 bg-gray-200 rounded-full mb-1">
        {/* Target range highlight */}
        <div
          className="absolute h-full bg-gray-400 rounded-full opacity-30"
          style={{
            left: `${targetMin}%`,
            width: `${targetMax - targetMin}%`
          }}
          aria-hidden="true"
        />

        {/* Trust level bar */}
        <div
          ref={barRef}
          className={`h-full rounded-full ${getColorClasses()}`}
          style={{
            width: `${Math.max(2, Math.min(100, value))}%`,
            transition: reducedMotion ? 'none' : 'width 0.3s ease-out'
          }}
          aria-hidden="true"
        />

        {/* Target range markers */}
        <div
          className="absolute top-0 w-px h-full bg-gray-600"
          style={{ left: `${targetMin}%` }}
          aria-hidden="true"
          title={`Target minimum: ${targetMin}%`}
        />
        <div
          className="absolute top-0 w-px h-full bg-gray-600"
          style={{ left: `${targetMax}%` }}
          aria-hidden="true"
          title={`Target maximum: ${targetMax}%`}
        />
      </div>

      {/* Target range labels */}
      <div className="flex justify-between text-xs text-gray-600 mt-1">
        <span>0%</span>
        <span className="text-gray-800 font-medium">
          Target: {targetMin}%-{targetMax}%
        </span>
        <span>100%</span>
      </div>

      {/* Feedback text */}
      <div className="mt-2 text-sm text-gray-700" aria-live="polite">
        {feedback}
      </div>

      {/* Screen reader only detailed info */}
      <div className="sr-only">
        Trust level: {Math.round(value)} percent.
        Target range: {targetMin} to {targetMax} percent.
        Current status: {getZoneText()}.
        {feedback}
      </div>
    </div>
  );
}

// Compact version for mobile/small spaces
export function CompactTrustBar({
  value,
  zone,
  className = ''
}: Pick<TrustBarProps, 'value' | 'zone' | 'className'>) {
  const [targetMin, targetMax] = TARGET_RANGE;
  const getZoneIcon = () => {
    switch (zone) {
      case 'too_high': return '⚠️';
      case 'too_low': return '🔒';
      case 'optimal': return '✅';
    }
  };

  return (
    <div className={`flex items-center gap-2 ${className}`} role="meter" aria-label="Trust level">
      <span className="text-lg" aria-hidden="true">{getZoneIcon()}</span>
      <div className="flex-1 h-1 bg-gray-200 rounded-full relative">
        <div
          className={`h-full rounded-full ${zone === 'optimal' ? 'bg-green-500' : zone === 'too_high' ? 'bg-red-500' : 'bg-blue-500'}`}
          style={{ width: `${Math.max(2, Math.min(100, value))}%` }}
          aria-hidden="true"
        />
      </div>
      <span className="text-sm font-medium">{Math.round(value)}%</span>
      <span className="sr-only">
        Trust level {Math.round(value)} percent, {zone === 'optimal' ? 'on target' : zone === 'too_high' ? 'too high' : 'too low'}
      </span>
    </div>
  );
}