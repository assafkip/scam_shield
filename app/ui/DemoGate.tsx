// Demo Gate Component - PRD-02 v2.1
// Auto-launches 30-second demo scenario on first app use

import React, { useState, useEffect } from 'react';
import { shouldAutoLaunchDemo } from '../engine/featureFlags';

interface DemoGateProps {
  onStartDemo: () => void;
  onSkipDemo: () => void;
  onContinueToApp: () => void;
  className?: string;
}

export function DemoGate({
  onStartDemo,
  onSkipDemo,
  onContinueToApp,
  className = ''
}: DemoGateProps) {
  const [isFirstVisit, setIsFirstVisit] = useState(false);
  const [countdown, setCountdown] = useState(5);
  const [autoLaunch, setAutoLaunch] = useState(false);

  useEffect(() => {
    // Check if this is the first visit
    const hasVisited = localStorage.getItem('scamshield_visited');
    const shouldShow = !hasVisited && shouldAutoLaunchDemo();

    if (shouldShow) {
      setIsFirstVisit(true);
      localStorage.setItem('scamshield_visited', 'true');

      // Auto-launch countdown
      const timer = setInterval(() => {
        setCountdown(prev => {
          if (prev <= 1) {
            setAutoLaunch(true);
            clearInterval(timer);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

      return () => clearInterval(timer);
    } else {
      // Not first visit, proceed to app
      onContinueToApp();
    }
  }, [onContinueToApp]);

  useEffect(() => {
    if (autoLaunch) {
      onStartDemo();
    }
  }, [autoLaunch, onStartDemo]);

  if (!isFirstVisit) {
    return null;
  }

  return (
    <div className={`demo-gate fixed inset-0 bg-blue-600 flex items-center justify-center ${className}`}>
      <div className="max-w-md mx-auto p-8 text-center text-white">
        {/* Welcome Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-4">Welcome to ScamShield</h1>
          <p className="text-xl text-blue-100">
            Learn to spot scams in under 30 seconds
          </p>
        </div>

        {/* Demo Preview */}
        <div className="bg-white/10 backdrop-blur rounded-lg p-6 mb-8">
          <h2 className="text-lg font-semibold mb-3">Quick Demo Preview</h2>
          <div className="text-left text-blue-100 space-y-2">
            <div className="flex items-center gap-2">
              <span className="text-green-300">✓</span>
              <span>Spot urgent pressure tactics</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-green-300">✓</span>
              <span>See trust level feedback</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-green-300">✓</span>
              <span>Learn red flag patterns</span>
            </div>
          </div>
        </div>

        {/* Auto-launch countdown */}
        {countdown > 0 && (
          <div className="mb-6">
            <div className="text-sm text-blue-200 mb-2">
              Demo starts automatically in:
            </div>
            <div className="text-4xl font-bold text-yellow-300">
              {countdown}
            </div>
          </div>
        )}

        {/* Action buttons */}
        <div className="space-y-4">
          <button
            onClick={onStartDemo}
            className="w-full px-6 py-4 bg-green-500 text-white rounded-lg hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-400 focus:ring-offset-2 focus:ring-offset-blue-600 transition-colors text-lg font-medium"
            disabled={autoLaunch}
          >
            {autoLaunch ? 'Starting Demo...' : '🚀 Start Quick Demo'}
          </button>

          <div className="flex gap-3">
            <button
              onClick={onSkipDemo}
              className="flex-1 px-4 py-3 bg-white/20 text-white rounded-lg hover:bg-white/30 focus:outline-none focus:ring-2 focus:ring-white/50 focus:ring-offset-2 focus:ring-offset-blue-600 transition-colors"
              disabled={autoLaunch}
            >
              Skip Demo
            </button>

            <button
              onClick={onContinueToApp}
              className="flex-1 px-4 py-3 bg-white/20 text-white rounded-lg hover:bg-white/30 focus:outline-none focus:ring-2 focus:ring-white/50 focus:ring-offset-2 focus:ring-offset-blue-600 transition-colors"
              disabled={autoLaunch}
            >
              Go to App
            </button>
          </div>
        </div>

        {/* Demo info */}
        <div className="mt-6 text-sm text-blue-200">
          <p className="mb-2">
            <strong>Privacy:</strong> Everything runs offline. No data collection.
          </p>
          <p>
            <strong>Duration:</strong> Less than 30 seconds to complete.
          </p>
        </div>

        {/* Accessibility info */}
        <div className="sr-only">
          <p>
            Welcome to ScamShield. This is a quick demo that teaches scam detection.
            The demo will start automatically in {countdown} seconds,
            or you can start it now, skip it, or go directly to the main app.
          </p>
        </div>
      </div>
    </div>
  );
}

// Settings component to control demo behavior
export function DemoSettings({
  onEnableAutoDemo,
  onDisableAutoDemo,
  onResetFirstVisit,
  className = ''
}: {
  onEnableAutoDemo: () => void;
  onDisableAutoDemo: () => void;
  onResetFirstVisit: () => void;
  className?: string;
}) {
  const [autoLaunchEnabled, setAutoLaunchEnabled] = useState(shouldAutoLaunchDemo());
  const [hasVisited, setHasVisited] = useState(!!localStorage.getItem('scamshield_visited'));

  const handleToggleAutoLaunch = () => {
    if (autoLaunchEnabled) {
      onDisableAutoDemo();
      setAutoLaunchEnabled(false);
    } else {
      onEnableAutoDemo();
      setAutoLaunchEnabled(true);
    }
  };

  const handleResetFirstVisit = () => {
    localStorage.removeItem('scamshield_visited');
    setHasVisited(false);
    onResetFirstVisit();
  };

  return (
    <div className={`demo-settings bg-white rounded-lg border p-4 ${className}`}>
      <h3 className="text-lg font-semibold mb-4">Demo Settings</h3>

      <div className="space-y-4">
        {/* Auto-launch toggle */}
        <div className="flex items-center justify-between">
          <div>
            <div className="font-medium">Auto-launch Demo</div>
            <div className="text-sm text-gray-600">
              Automatically start demo for new users
            </div>
          </div>
          <button
            onClick={handleToggleAutoLaunch}
            className={`
              relative inline-flex h-6 w-11 items-center rounded-full transition-colors
              ${autoLaunchEnabled ? 'bg-blue-600' : 'bg-gray-200'}
            `}
            role="switch"
            aria-checked={autoLaunchEnabled}
          >
            <span
              className={`
                inline-block h-4 w-4 transform rounded-full bg-white transition-transform
                ${autoLaunchEnabled ? 'translate-x-6' : 'translate-x-1'}
              `}
            />
          </button>
        </div>

        {/* Reset first visit */}
        <div className="flex items-center justify-between">
          <div>
            <div className="font-medium">Reset First Visit</div>
            <div className="text-sm text-gray-600">
              {hasVisited ? 'User has visited before' : 'First-time visitor'}
            </div>
          </div>
          <button
            onClick={handleResetFirstVisit}
            disabled={!hasVisited}
            className="px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Reset
          </button>
        </div>
      </div>
    </div>
  );
}