// Service Worker - PRD-02 v2.1
// Offline-first caching for ScamShield app shell and scenarios

declare const self: ServiceWorkerGlobalScope;

const VERSION = 'v1.1.0';
const CACHE_NAME = `scamshield-${VERSION}`;

// Core app files to cache immediately
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/main.js',
  '/styles.css',
  '/manifest.json',
  '/assets/icons/icon-192.png',
  '/assets/icons/icon-512.png'
];

// Essential scenarios to cache for offline demo
const PRIORITY_SCENARIOS = [
  '/assets/scenarios/demo_quickstart.json',
  '/assets/scenarios/whatsapp_ceo_urgent.json',
  '/assets/scenarios/paypal_security_legitimate.json'
];

// Internationalization files
const I18N_FILES = [
  '/i18n/en-US.json'
];

// Runtime configuration
const CONFIG_FILES = [
  '/config/runtime.json'
];

// All files to precache
const ALL_PRECACHE = [
  ...PRECACHE_URLS,
  ...PRIORITY_SCENARIOS,
  ...I18N_FILES,
  ...CONFIG_FILES
];

// Cache strategies
const CACHE_STRATEGIES = {
  // App shell - cache first, network fallback
  app: {
    cacheName: `${CACHE_NAME}-app`,
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    patterns: [/\/$/, /\/index\.html$/, /\.(js|css)$/]
  },

  // Scenarios - cache first, network update
  scenarios: {
    cacheName: `${CACHE_NAME}-scenarios`,
    maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
    patterns: [/\/assets\/scenarios\/.*\.json$/]
  },

  // Images and static assets - cache first
  assets: {
    cacheName: `${CACHE_NAME}-assets`,
    maxAge: 90 * 24 * 60 * 60 * 1000, // 90 days
    patterns: [/\.(png|jpg|jpeg|svg|ico|woff2)$/]
  },

  // Config and i18n - network first, cache fallback
  config: {
    cacheName: `${CACHE_NAME}-config`,
    maxAge: 24 * 60 * 60 * 1000, // 1 day
    patterns: [/\/(config|i18n)\/.*\.json$/]
  }
};

// Install event - precache essential files
self.addEventListener('install', (event: ExtendableEvent) => {
  console.log('[SW] Installing service worker version', VERSION);

  event.waitUntil(
    caches.open(CACHE_STRATEGIES.app.cacheName)
      .then(cache => {
        console.log('[SW] Precaching app shell and priority content');
        return cache.addAll(ALL_PRECACHE);
      })
      .then(() => {
        console.log('[SW] Precaching complete');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('[SW] Precaching failed:', error);
        // Don't prevent installation - app can work with partial cache
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event: ExtendableEvent) => {
  console.log('[SW] Activating service worker version', VERSION);

  event.waitUntil(
    caches.keys()
      .then(cacheNames => {
        return Promise.all(
          cacheNames.map(cacheName => {
            if (cacheName.startsWith('scamshield-') && !cacheName.includes(VERSION)) {
              console.log('[SW] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('[SW] Cache cleanup complete');
        return self.clients.claim();
      })
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', (event: FetchEvent) => {
  const url = new URL(event.request.url);

  // Only handle same-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request: Request): Promise<Response> {
  const url = new URL(request.url);
  const pathname = url.pathname;

  // Determine caching strategy based on URL pattern
  const strategy = getStrategyForUrl(pathname);

  switch (strategy.name) {
    case 'app':
      return cacheFirst(request, strategy);
    case 'scenarios':
      return cacheFirst(request, strategy);
    case 'assets':
      return cacheFirst(request, strategy);
    case 'config':
      return networkFirst(request, strategy);
    default:
      return networkFirst(request, strategy);
  }
}

function getStrategyForUrl(pathname: string): { name: string; strategy: any } {
  for (const [name, strategy] of Object.entries(CACHE_STRATEGIES)) {
    if (strategy.patterns.some(pattern => pattern.test(pathname))) {
      return { name, strategy };
    }
  }
  return { name: 'default', strategy: CACHE_STRATEGIES.config };
}

// Cache first strategy - serve from cache, fallback to network
async function cacheFirst(request: Request, { strategy }: any): Promise<Response> {
  try {
    const cache = await caches.open(strategy.cacheName);
    const cachedResponse = await cache.match(request);

    if (cachedResponse) {
      // Check if cached response is still fresh
      const cachedAt = cachedResponse.headers.get('sw-cached-at');
      if (cachedAt) {
        const age = Date.now() - parseInt(cachedAt);
        if (age > strategy.maxAge) {
          // Cached response is stale, try to update in background
          updateCacheInBackground(request, cache);
        }
      }

      return cachedResponse;
    }

    // Not in cache, fetch from network
    const networkResponse = await fetch(request);

    if (networkResponse.ok) {
      // Clone response to cache
      const responseToCache = networkResponse.clone();

      // Add timestamp header
      const headers = new Headers(responseToCache.headers);
      headers.set('sw-cached-at', Date.now().toString());

      const modifiedResponse = new Response(responseToCache.body, {
        status: responseToCache.status,
        statusText: responseToCache.statusText,
        headers
      });

      cache.put(request, modifiedResponse);
    }

    return networkResponse;

  } catch (error) {
    console.error('[SW] Cache first strategy failed:', error);

    // If network fails, try to serve any cached version (even stale)
    const cache = await caches.open(strategy.cacheName);
    const cachedResponse = await cache.match(request);

    if (cachedResponse) {
      console.log('[SW] Serving stale cached response');
      return cachedResponse;
    }

    // Ultimate fallback for app shell
    if (request.mode === 'navigate') {
      const indexCache = await caches.open(CACHE_STRATEGIES.app.cacheName);
      const indexResponse = await indexCache.match('/index.html');
      if (indexResponse) {
        return indexResponse;
      }
    }

    throw error;
  }
}

// Network first strategy - try network, fallback to cache
async function networkFirst(request: Request, { strategy }: any): Promise<Response> {
  try {
    const networkResponse = await fetch(request);

    if (networkResponse.ok) {
      // Update cache with fresh response
      const cache = await caches.open(strategy.cacheName);
      const responseToCache = networkResponse.clone();

      const headers = new Headers(responseToCache.headers);
      headers.set('sw-cached-at', Date.now().toString());

      const modifiedResponse = new Response(responseToCache.body, {
        status: responseToCache.status,
        statusText: responseToCache.statusText,
        headers
      });

      cache.put(request, modifiedResponse);
    }

    return networkResponse;

  } catch (error) {
    console.log('[SW] Network failed, trying cache:', error.message);

    // Network failed, try cache
    const cache = await caches.open(strategy.cacheName);
    const cachedResponse = await cache.match(request);

    if (cachedResponse) {
      return cachedResponse;
    }

    throw error;
  }
}

// Background cache update
async function updateCacheInBackground(request: Request, cache: Cache): Promise<void> {
  try {
    console.log('[SW] Updating cache in background for:', request.url);
    const networkResponse = await fetch(request);

    if (networkResponse.ok) {
      const headers = new Headers(networkResponse.headers);
      headers.set('sw-cached-at', Date.now().toString());

      const modifiedResponse = new Response(networkResponse.body, {
        status: networkResponse.status,
        statusText: networkResponse.statusText,
        headers
      });

      await cache.put(request, modifiedResponse);
      console.log('[SW] Background cache update successful');
    }
  } catch (error) {
    console.warn('[SW] Background cache update failed:', error);
  }
}

// Message handling for cache management
self.addEventListener('message', (event: ExtendableMessageEvent) => {
  if (event.data && event.data.type === 'GET_CACHE_STATUS') {
    getCacheStatus().then(status => {
      event.ports[0].postMessage({ type: 'CACHE_STATUS', status });
    });
  }

  if (event.data && event.data.type === 'CLEAR_CACHE') {
    clearAllCaches().then(() => {
      event.ports[0].postMessage({ type: 'CACHE_CLEARED' });
    });
  }
});

async function getCacheStatus(): Promise<any> {
  const status = {
    version: VERSION,
    caches: {},
    totalSize: 0,
    scenarioCount: 0
  };

  try {
    for (const [name, strategy] of Object.entries(CACHE_STRATEGIES)) {
      const cache = await caches.open(strategy.cacheName);
      const keys = await cache.keys();

      status.caches[name] = {
        name: strategy.cacheName,
        requestCount: keys.length,
        urls: keys.map(req => req.url)
      };

      if (name === 'scenarios') {
        status.scenarioCount = keys.length;
      }
    }
  } catch (error) {
    console.error('[SW] Failed to get cache status:', error);
  }

  return status;
}

async function clearAllCaches(): Promise<void> {
  try {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames
        .filter(name => name.startsWith('scamshield-'))
        .map(name => caches.delete(name))
    );
    console.log('[SW] All caches cleared');
  } catch (error) {
    console.error('[SW] Failed to clear caches:', error);
  }
}

// Export for type checking
export {};