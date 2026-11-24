/* =========================================================
   SERVICE WORKER: Powers Offline Mode & Cached Map Tiles
   ========================================================= */

const APP_CACHE = "sabah-malaria-app-v1";
const TILE_CACHE = "sabah-malaria-tiles-v1";

// Core files needed so the app opens with zero internet signal
const APP_FILES = [
  "./",
  "./index.html",
  "./manifest.json",
  "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css",
  "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"
];

// 1. INSTALL: Save core app files into the phone's cache
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(APP_CACHE).then((cache) => cache.addAll(APP_FILES))
  );
  self.skipWaiting();
});

// 2. ACTIVATE: Clean up old app caches if we release a new version
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== APP_CACHE && key !== TILE_CACHE)
          .map((oldKey) => caches.delete(oldKey))
      )
    )
  );
  self.clients.claim();
});

// 3. FETCH: Serve cached map tiles & app files when offline
self.addEventListener("fetch", (event) => {
  const url = event.request.url;

  // Strategy A: Esri Map Tiles -> Check Cache first, otherwise download & save
  if (url.includes("server.arcgisonline.com")) {
    event.respondWith(
      caches.open(TILE_CACHE).then(async (cache) => {
        const cachedTile = await cache.match(event.request);
        if (cachedTile) return cachedTile;

        try {
          const networkResponse = await fetch(event.request);
          if (networkResponse.ok || networkResponse.type === "opaque") {
            cache.put(event.request, networkResponse.clone());
          }
          return networkResponse;
        } catch {
          return new Response("", { status: 404 });
        }
      })
    );
    return;
  }

  // Strategy B: App Files -> Try network first, fall back to cache if offline
  event.respondWith(
    fetch(event.request)
      .then((networkResponse) => {
        if (networkResponse.ok && event.request.method === "GET") {
          const copy = networkResponse.clone();
          caches.open(APP_CACHE).then((cache) => cache.put(event.request, copy));
        }
        return networkResponse;
      })
      .catch(() => caches.match(event.request))
  );
});