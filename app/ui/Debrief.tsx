// Enhanced Debrief Component - PRD-02 v2.1
// Shows trust analysis, pressure timeline, and red flag education

import React from 'react';
import { TrustBar } from './TrustBar';
import { PressureMeter } from './PressureMeter';
import { analyzeTrustPerformance, analyzePressureResistance } from '../engine/trustPressure';
import type { TrustPressureTrace } from '../../schema/unified.types';

interface DebriefProps {
  // Final scores
  finalTrust: number;
  finalPressure: number;
  traces: TrustPressureTrace[];

  // Scenario content
  redFlagPrimary: string;
  redFlagSecondary?: string[];
  teachingPoints: string[];
  scenarioTitle: string;

  // Actions
  onReplay?: () => void;
  onNextScenario?: () => void;
  onReturnToMenu?: () => void;

  className?: string;
}

export function Debrief({
  finalTrust,
  finalPressure,
  traces,
  redFlagPrimary,
  redFlagSecondary = [],
  teachingPoints,
  scenarioTitle,
  onReplay,
  onNextScenario,
  onReturnToMenu,
  className = ''
}: DebriefProps) {
  const trustAnalysis = analyzeTrustPerformance(finalTrust);
  const pressureAnalysis = analyzePressureResistance(traces);

  return (
    <div className={`debrief-screen max-w-4xl mx-auto p-6 ${className}`}>
      {/* Header */}
      <header className="text-center mb-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Scenario Complete</h1>
        <h2 className="text-lg text-gray-600">{scenarioTitle}</h2>
      </header>

      {/* Trust & Pressure Analysis */}
      <section className="grid md:grid-cols-2 gap-6 mb-8">
        {/* Trust Analysis */}
        <div className="bg-white rounded-lg border p-6">
          <h3 className="text-lg font-semibold mb-4">Trust Analysis</h3>
          <TrustBar
            value={finalTrust}
            feedback={trustAnalysis.message}
            zone={trustAnalysis.category === 'well_calibrated' ? 'optimal' :
                 trustAnalysis.category === 'too_trusting' ? 'too_high' : 'too_low'}
            className="mb-4"
          />
          <div className="text-sm text-gray-700">
            <strong>Recommendation:</strong> {trustAnalysis.recommendation}
          </div>
        </div>

        {/* Pressure Analysis */}
        <div className="bg-white rounded-lg border p-6">
          <h3 className="text-lg font-semibold mb-4">Pressure Resistance</h3>
          <div className="mb-4">
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm font-medium">Resistance Score</span>
              <span className="text-lg font-bold">
                {Math.round(pressureAnalysis.resistanceScore)}%
              </span>
            </div>
            <div className="h-2 bg-gray-200 rounded-full">
              <div
                className={`h-full rounded-full ${
                  pressureAnalysis.resistanceScore >= 70 ? 'bg-green-500' :
                  pressureAnalysis.resistanceScore >= 40 ? 'bg-yellow-500' : 'bg-red-500'
                }`}
                style={{ width: `${Math.max(5, pressureAnalysis.resistanceScore)}%` }}
              />
            </div>
          </div>
          <div className="text-sm text-gray-700">
            {pressureAnalysis.message}
          </div>
        </div>
      </section>

      {/* Red Flag Analysis */}
      <section className="bg-red-50 border border-red-200 rounded-lg p-6 mb-8">
        <h2 className="text-xl font-semibold text-red-800 mb-4 flex items-center">
          <span className="text-2xl mr-2" aria-hidden="true">🚩</span>
          Primary Red Flag
        </h2>

        <div className="bg-white rounded-lg p-4 mb-4">
          <p className="text-lg font-medium text-red-900 mb-2">
            {redFlagPrimary}
          </p>

          {redFlagSecondary.length > 0 && (
            <div className="mt-3">
              <h4 className="text-sm font-medium text-red-800 mb-2">Additional Red Flags:</h4>
              <ul className="list-disc list-inside text-sm text-red-700 space-y-1">
                {redFlagSecondary.map((flag, index) => (
                  <li key={index}>{flag}</li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </section>

      {/* Teaching Points */}
      <section className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-8">
        <h2 className="text-xl font-semibold text-blue-800 mb-4 flex items-center">
          <span className="text-2xl mr-2" aria-hidden="true">💡</span>
          Key Learning Points
        </h2>

        <ul className="space-y-3">
          {teachingPoints.map((point, index) => (
            <li key={index} className="flex items-start">
              <span className="flex-shrink-0 w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-medium mr-3 mt-0.5">
                {index + 1}
              </span>
              <span className="text-blue-900">{point}</span>
            </li>
          ))}
        </ul>
      </section>

      {/* Pressure Timeline (if available) */}
      {traces.length > 0 && (
        <section className="bg-gray-50 border border-gray-200 rounded-lg p-6 mb-8">
          <h2 className="text-xl font-semibold text-gray-800 mb-4">Pressure Timeline</h2>
          <PressureTimeline traces={traces} />
        </section>
      )}

      {/* Action Buttons */}
      <section className="flex flex-wrap gap-4 justify-center">
        {onReplay && (
          <button
            onClick={onReplay}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
          >
            🔄 Replay Scenario
          </button>
        )}

        {onNextScenario && (
          <button
            onClick={onNextScenario}
            className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors"
          >
            ➡️ Try Next Scenario
          </button>
        )}

        {onReturnToMenu && (
          <button
            onClick={onReturnToMenu}
            className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-colors"
          >
            🏠 Return to Menu
          </button>
        )}
      </section>

      {/* Accessibility summary for screen readers */}
      <div className="sr-only">
        <h2>Scenario Summary for Screen Reader</h2>
        <p>
          You completed {scenarioTitle}.
          Final trust level: {Math.round(finalTrust)}% ({trustAnalysis.category}).
          Pressure resistance: {Math.round(pressureAnalysis.resistanceScore)}%.
          Primary red flag: {redFlagPrimary}.
          {teachingPoints.length} key learning points were identified.
        </p>
      </div>
    </div>
  );
}

// Timeline visualization component
function PressureTimeline({ traces }: { traces: TrustPressureTrace[] }) {
  if (traces.length === 0) return null;

  const maxPressure = Math.max(...traces.map(t => Math.max(t.pressureBefore, t.pressureAfter)));
  const scale = 100; // Height in pixels

  return (
    <div className="pressure-timeline">
      <div className="flex items-end justify-center gap-2 h-24 mb-4">
        {traces.map((trace, index) => {
          const height = (trace.pressureAfter / maxPressure) * scale;
          const delta = trace.pressureAfter - trace.pressureBefore;
          const isIncrease = delta > 0;
          const isSignificant = Math.abs(delta) >= 5;

          return (
            <div
              key={`${trace.stepId}-${index}`}
              className="flex flex-col items-center"
            >
              <div
                className={`
                  w-6 rounded-t transition-all duration-300
                  ${isIncrease ? 'bg-red-400' : 'bg-green-400'}
                  ${isSignificant ? 'border-2 border-gray-800' : 'border border-gray-400'}
                `}
                style={{ height: `${Math.max(4, height * 0.6)}px` }}
                title={`Step ${index + 1}: ${Math.round(trace.pressureAfter)}% pressure`}
              />
              <div className="text-xs text-gray-600 mt-1">
                {index + 1}
              </div>
            </div>
          );
        })}
      </div>

      <div className="flex justify-center gap-4 text-sm text-gray-600">
        <div className="flex items-center gap-2">
          <div className="w-4 h-4 bg-red-400 rounded" />
          <span>Pressure Increased</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-4 h-4 bg-green-400 rounded" />
          <span>Pressure Resisted</span>
        </div>
      </div>

      <div className="mt-4 text-center text-sm text-gray-600">
        Timeline shows pressure changes at each decision point
      </div>
    </div>
  );
}