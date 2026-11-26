/* =========================================================
   SERVICE WORKER (v8): Offline Support + Supabase Pass-Through
   ========================================================= */

const APP_CACHE = "sabah-malaria-app-v8";
const TILE_CACHE = "sabah-malaria-tiles-v1";

const APP_FILES = [
  "./",
  "./index.html",
  "./manifest.json",
  "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css",
  "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js",
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(APP_CACHE).then((cache) => cache.addAll(APP_FILES))
  );
  self.skipWaiting();
});

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

self.addEventListener("fetch", (event) => {
  const url = event.request.url;

  if (url.includes(".supabase.co")) {
    return;
  }

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
