// Pressure Meter Component - PRD-02 v2.1
// Shows pressure buildup with haptic feedback and timeline visualization

import React, { useEffect, useRef, useState } from 'react';
import { debouncedHapticSpike } from '../engine/haptics';
import { announcePressureChange } from '../engine/liveRegions';
import { shouldUseHaptics, shouldReduceMotion } from '../engine/featureFlags';
import type { TrustPressureTrace } from '../../schema/unified.types';

interface PressureMeterProps {
  value: number;
  previousValue?: number;
  feedback: string;
  zone: 'safe' | 'caution' | 'danger' | 'critical';
  timeline?: TrustPressureTrace[];
  className?: string;
  variant?: 'full' | 'compact' | 'thermometer';
}

export function PressureMeter({
  value,
  previousValue = value,
  feedback,
  zone,
  timeline = [],
  className = '',
  variant = 'full'
}: PressureMeterProps) {
  const meterRef = useRef<HTMLDivElement>(null);
  const [isAnimating, setIsAnimating] = useState(false);
  const delta = value - previousValue;
  const shouldTriggerHaptic = delta >= 5 && shouldUseHaptics();

  // Trigger haptic feedback on pressure spikes
  useEffect(() => {
    if (shouldTriggerHaptic) {
      debouncedHapticSpike();
      setIsAnimating(true);
      setTimeout(() => setIsAnimating(false), 300);
    }
  }, [shouldTriggerHaptic]);

  // Announce pressure changes for screen readers
  useEffect(() => {
    if (Math.abs(delta) >= 5 || zone === 'critical') {
      announcePressureChange(value, feedback, zone, delta);
    }
  }, [value, feedback, zone, delta]);

  const getZoneColor = () => {
    switch (zone) {
      case 'safe': return 'bg-green-500';
      case 'caution': return 'bg-yellow-500';
      case 'danger': return 'bg-orange-500';
      case 'critical': return 'bg-red-500';
    }
  };

  const getZoneText = () => {
    switch (zone) {
      case 'safe': return 'Safe';
      case 'caution': return 'Caution';
      case 'danger': return 'Danger';
      case 'critical': return 'Critical';
    }
  };

  const reducedMotion = shouldReduceMotion();

  if (variant === 'compact') {
    return <CompactPressureMeter value={value} zone={zone} className={className} />;
  }

  if (variant === 'thermometer') {
    return <ThermometerPressureMeter value={value} zone={zone} className={className} />;
  }

  return (
    <div className={`pressure-meter ${className}`} role="meter" aria-labelledby="pressure-label">
      {/* Label and value */}
      <div id="pressure-label" className="text-sm font-medium mb-2 flex justify-between items-center">
        <span>Pressure Level</span>
        <span className={`text-sm px-2 py-1 rounded ${getZoneColor()} text-white`}>
          {Math.round(value)}% ({getZoneText()})
        </span>
      </div>

      {/* Pressure bar */}
      <div className="relative h-4 bg-gray-200 rounded-lg overflow-hidden">
        {/* Zone indicators */}
        <div className="absolute inset-0 flex">
          <div className="w-1/4 bg-green-200 opacity-50" aria-hidden="true" />
          <div className="w-1/4 bg-yellow-200 opacity-50" aria-hidden="true" />
          <div className="w-1/4 bg-orange-200 opacity-50" aria-hidden="true" />
          <div className="w-1/4 bg-red-200 opacity-50" aria-hidden="true" />
        </div>

        {/* Pressure level */}
        <div
          ref={meterRef}
          className={`
            h-full ${getZoneColor()} relative
            ${isAnimating && !reducedMotion ? 'animate-pulse' : ''}
          `}
          style={{
            width: `${Math.max(2, Math.min(100, value))}%`,
            transition: reducedMotion ? 'none' : 'width 0.5s ease-out'
          }}
          aria-hidden="true"
        >
          {/* Spike indicator */}
          {delta >= 5 && !reducedMotion && (
            <div className="absolute right-0 top-0 h-full w-1 bg-white opacity-80 animate-ping" />
          )}
        </div>

        {/* Zone boundaries */}
        {[25, 50, 75].map((boundary, index) => (
          <div
            key={boundary}
            className="absolute top-0 w-px h-full bg-gray-400"
            style={{ left: `${boundary}%` }}
            aria-hidden="true"
          />
        ))}
      </div>

      {/* Zone labels */}
      <div className="flex justify-between text-xs text-gray-600 mt-1">
        <span>Safe</span>
        <span>Caution</span>
        <span>Danger</span>
        <span>Critical</span>
      </div>

      {/* Feedback and timeline */}
      <div className="mt-3 space-y-2">
        <div className="text-sm text-gray-700" aria-live="polite">
          {feedback}
        </div>

        {timeline.length > 0 && (
          <PressureTimeline timeline={timeline} />
        )}
      </div>

      {/* Screen reader only detailed info */}
      <div className="sr-only">
        Pressure level: {Math.round(value)} percent.
        Zone: {getZoneText()}.
        {delta > 0 && `Increased by ${Math.round(delta)} points.`}
        {delta < 0 && `Decreased by ${Math.round(Math.abs(delta))} points.`}
        {feedback}
      </div>
    </div>
  );
}

// Compact pressure meter for small spaces
function CompactPressureMeter({
  value,
  zone,
  className = ''
}: Pick<PressureMeterProps, 'value' | 'zone' | 'className'>) {
  const getZoneIcon = () => {
    switch (zone) {
      case 'safe': return '🟢';
      case 'caution': return '🟡';
      case 'danger': return '🟠';
      case 'critical': return '🔴';
    }
  };

  return (
    <div className={`flex items-center gap-2 ${className}`} role="meter" aria-label="Pressure level">
      <span className="text-lg" aria-hidden="true">{getZoneIcon()}</span>
      <div className="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
        <div
          className={`h-full ${zone === 'safe' ? 'bg-green-500' : zone === 'caution' ? 'bg-yellow-500' : zone === 'danger' ? 'bg-orange-500' : 'bg-red-500'}`}
          style={{ width: `${Math.max(2, Math.min(100, value))}%` }}
          aria-hidden="true"
        />
      </div>
      <span className="text-sm font-medium">{Math.round(value)}%</span>
      <span className="sr-only">
        Pressure level {Math.round(value)} percent, {zone} zone
      </span>
    </div>
  );
}

// Thermometer-style vertical pressure meter
function ThermometerPressureMeter({
  value,
  zone,
  className = ''
}: Pick<PressureMeterProps, 'value' | 'zone' | 'className'>) {
  return (
    <div className={`flex flex-col items-center ${className}`} role="meter" aria-label="Pressure thermometer">
      {/* Scale markers */}
      <div className="text-xs text-gray-600 mb-1">100%</div>

      {/* Thermometer body */}
      <div className="w-6 h-32 bg-gray-200 rounded-full relative overflow-hidden">
        {/* Zone backgrounds */}
        <div className="absolute bottom-0 w-full h-1/4 bg-red-100" aria-hidden="true" />
        <div className="absolute bottom-1/4 w-full h-1/4 bg-orange-100" aria-hidden="true" />
        <div className="absolute bottom-2/4 w-full h-1/4 bg-yellow-100" aria-hidden="true" />
        <div className="absolute bottom-3/4 w-full h-1/4 bg-green-100" aria-hidden="true" />

        {/* Mercury fill */}
        <div
          className={`absolute bottom-0 w-full rounded-full ${zone === 'safe' ? 'bg-green-500' : zone === 'caution' ? 'bg-yellow-500' : zone === 'danger' ? 'bg-orange-500' : 'bg-red-500'}`}
          style={{ height: `${Math.max(2, Math.min(100, value))}%` }}
          aria-hidden="true"
        />
      </div>

      <div className="text-xs text-gray-600 mt-1">0%</div>
      <div className="text-sm font-medium mt-2">{Math.round(value)}%</div>

      <span className="sr-only">
        Pressure thermometer showing {Math.round(value)} percent in {zone} zone
      </span>
    </div>
  );
}

// Timeline component showing pressure changes over time
function PressureTimeline({ timeline }: { timeline: TrustPressureTrace[] }) {
  if (timeline.length === 0) return null;

  return (
    <div className="pressure-timeline">
      <h4 className="text-sm font-medium text-gray-800 mb-2">Pressure Timeline</h4>
      <div className="flex items-center gap-1 overflow-x-auto">
        {timeline.map((trace, index) => {
          const delta = trace.pressureAfter - trace.pressureBefore;
          const isIncrease = delta > 0;
          const isSignificant = Math.abs(delta) >= 5;

          return (
            <div
              key={`${trace.stepId}-${index}`}
              className={`
                flex-shrink-0 w-4 h-4 rounded-full border-2
                ${isSignificant ? 'border-gray-800' : 'border-gray-400'}
                ${isIncrease ? 'bg-red-300' : 'bg-green-300'}
              `}
              title={`Step ${trace.stepId}: ${isIncrease ? '+' : ''}${Math.round(delta)} pressure`}
              aria-label={`Pressure ${isIncrease ? 'increased' : 'decreased'} by ${Math.abs(Math.round(delta))} points`}
            />
          );
        })}
      </div>
      <div className="flex justify-between text-xs text-gray-600 mt-1">
        <span>🔴 Escalation</span>
        <span>🟢 Resistance</span>
      </div>
    </div>
  );
}