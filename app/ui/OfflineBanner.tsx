// Offline Banner Component - PRD-02 v2.1
// Shows offline status and cached content availability

import React, { useState, useEffect } from 'react';

interface OfflineBannerProps {
  className?: string;
  onDismiss?: () => void;
}

export function OfflineBanner({ className = '', onDismiss }: OfflineBannerProps) {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [isDismissed, setIsDismissed] = useState(false);
  const [cachedScenariosCount, setCachedScenariosCount] = useState(0);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Check cached scenarios count
    checkCachedScenarios();

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const checkCachedScenarios = async () => {
    try {
      if ('caches' in window) {
        const cache = await caches.open('v1');
        const requests = await cache.keys();
        const scenarioRequests = requests.filter(req =>
          req.url.includes('/assets/scenarios/') && req.url.endsWith('.json')
        );
        setCachedScenariosCount(scenarioRequests.length);
      }
    } catch (error) {
      console.debug('Failed to check cached scenarios:', error);
    }
  };

  const handleDismiss = () => {
    setIsDismissed(true);
    onDismiss?.();
  };

  // Don't show banner if online or dismissed
  if (isOnline || isDismissed) {
    return null;
  }

  return (
    <div className={`offline-banner bg-amber-50 border border-amber-200 ${className}`}>
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <div className="flex-shrink-0">
            <span className="text-2xl" role="img" aria-label="Offline">📱</span>
          </div>

          <div className="flex-1">
            <h3 className="text-sm font-medium text-amber-800">
              You're offline
            </h3>
            <p className="text-sm text-amber-700">
              {cachedScenariosCount > 0 ? (
                <>
                  {cachedScenariosCount} scenario{cachedScenariosCount !== 1 ? 's' : ''} available offline.
                  All features work without internet.
                </>
              ) : (
                'ScamShield works fully offline. No internet required.'
              )}
            </p>
          </div>
        </div>

        <div className="flex-shrink-0 flex gap-2">
          {/* Cached content indicator */}
          {cachedScenariosCount > 0 && (
            <div className="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full font-medium">
              {cachedScenariosCount} cached
            </div>
          )}

          {/* Dismiss button */}
          <button
            onClick={handleDismiss}
            className="text-amber-600 hover:text-amber-800 focus:outline-none focus:text-amber-800"
            aria-label="Dismiss offline notification"
          >
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
            </svg>
          </button>
        </div>
      </div>

      {/* Additional offline features info */}
      <div className="border-t border-amber-200 bg-amber-25 px-4 py-3">
        <div className="flex flex-wrap gap-4 text-xs text-amber-700">
          <div className="flex items-center gap-1">
            <span className="text-green-600">✓</span>
            <span>Trust & pressure feedback</span>
          </div>
          <div className="flex items-center gap-1">
            <span className="text-green-600">✓</span>
            <span>Scenario completion</span>
          </div>
          <div className="flex items-center gap-1">
            <span className="text-green-600">✓</span>
            <span>Learning progress</span>
          </div>
          <div className="flex items-center gap-1">
            <span className="text-green-600">✓</span>
            <span>Accessibility features</span>
          </div>
        </div>
      </div>

      {/* Screen reader announcement */}
      <div className="sr-only" aria-live="polite">
        You are currently offline. ScamShield works fully offline with {cachedScenariosCount} scenarios available.
        All features including trust feedback, pressure meters, and learning progress work without internet connection.
      </div>
    </div>
  );
}

// Connection status indicator (for header/status bar)
export function ConnectionStatus({ className = '' }: { className?: string }) {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const statusColor = isOnline ? 'text-green-600' : 'text-amber-600';
  const statusIcon = isOnline ? '🟢' : '🟡';
  const statusText = isOnline ? 'Online' : 'Offline';

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <span role="img" aria-hidden="true">{statusIcon}</span>
      <span className={`text-sm font-medium ${statusColor}`}>
        {statusText}
      </span>
      <span className="sr-only">
        Connection status: {statusText}. {isOnline ? 'Connected to internet.' : 'App works fully offline.'}
      </span>
    </div>
  );
}

// Service worker registration status
export function ServiceWorkerStatus({ className = '' }: { className?: string }) {
  const [swStatus, setSWStatus] = useState<'loading' | 'ready' | 'error' | 'unsupported'>('loading');

  useEffect(() => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.ready
        .then(() => setSWStatus('ready'))
        .catch(() => setSWStatus('error'));
    } else {
      setSWStatus('unsupported');
    }
  }, []);

  if (swStatus === 'loading') {
    return null;
  }

  const getStatusInfo = () => {
    switch (swStatus) {
      case 'ready':
        return { icon: '✅', text: 'Cached', color: 'text-green-600' };
      case 'error':
        return { icon: '⚠️', text: 'Cache Error', color: 'text-amber-600' };
      case 'unsupported':
        return { icon: '❌', text: 'No Cache', color: 'text-gray-600' };
    }
  };

  const { icon, text, color } = getStatusInfo();

  return (
    <div className={`flex items-center gap-2 ${className}`} title="Offline caching status">
      <span role="img" aria-hidden="true">{icon}</span>
      <span className={`text-xs ${color}`}>{text}</span>
      <span className="sr-only">
        Offline caching status: {text}.
        {swStatus === 'ready' && 'App content is cached for offline use.'}
        {swStatus === 'error' && 'Some content may not be available offline.'}
        {swStatus === 'unsupported' && 'Offline caching not supported in this browser.'}
      </span>
    </div>
  );
}