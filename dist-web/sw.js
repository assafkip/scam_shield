// Service Worker - PRD-02 v2.1
// Offline-first caching for ScamShield web deployment

const VERSION = 'v2.1.0';
const CACHE_NAME = `scamshield-${VERSION}`;

// Core app files to cache immediately
const PRECACHE_URLS = [
  './',
  './index.html',
  './app.js',
  './styles.css',
  './manifest.json',
  './health.txt',
  './config/runtime.json'
];

// Install event - precache essential files
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker version', VERSION);

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[SW] Precaching app shell');
        return cache.addAll(PRECACHE_URLS);
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
self.addEventListener('activate', (event) => {
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
self.addEventListener('fetch', (event) => {
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

async function handleRequest(request) {
  const url = new URL(request.url);
  const pathname = url.pathname;

  try {
    // Try cache first for all resources
    const cache = await caches.open(CACHE_NAME);
    const cachedResponse = await cache.match(request);

    if (cachedResponse) {
      console.log('[SW] Serving from cache:', pathname);
      return cachedResponse;
    }

    // Not in cache, fetch from network
    const networkResponse = await fetch(request);

    if (networkResponse.ok) {
      // Clone response to cache
      const responseToCache = networkResponse.clone();
      cache.put(request, responseToCache);
      console.log('[SW] Cached new resource:', pathname);
    }

    return networkResponse;

  } catch (error) {
    console.error('[SW] Fetch failed:', error);

    // If network fails, try to serve any cached version
    const cache = await caches.open(CACHE_NAME);
    const cachedResponse = await cache.match(request);

    if (cachedResponse) {
      console.log('[SW] Serving stale cached response for:', pathname);
      return cachedResponse;
    }

    // Ultimate fallback for navigation requests
    if (request.mode === 'navigate') {
      const indexResponse = await cache.match('./index.html');
      if (indexResponse) {
        console.log('[SW] Serving index.html for navigation fallback');
        return indexResponse;
      }
    }

    throw error;
  }
}

// Message handling for cache management
self.addEventListener('message', (event) => {
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

async function getCacheStatus() {
  const status = {
    version: VERSION,
    totalSize: 0,
    requestCount: 0
  };

  try {
    const cache = await caches.open(CACHE_NAME);
    const keys = await cache.keys();

    status.requestCount = keys.length;
    status.urls = keys.map(req => req.url);
  } catch (error) {
    console.error('[SW] Failed to get cache status:', error);
  }

  return status;
}

async function clearAllCaches() {
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
console.log('[SW] ScamShield Service Worker loaded, version', VERSION);