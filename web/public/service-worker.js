importScripts('https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js');

var CACHE_VERSION = 'v1';
var CACHE_NAME = CACHE_VERSION + ':sw-cache-';

if (workbox) {
  console.log(`Yay! Workbox is loaded 🎉`);
} else {
  console.log(`Boo! Workbox didn't load 😬`);
}

workbox.routing.registerRoute(
  /^https:\/\/fonts\.googleapis\.com/,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE_NAME + 'google-fonts-stylesheets',
  })
);

workbox.routing.registerRoute(
  /^https:\/\/fonts\.gstatic\.com/,
  new workbox.strategies.CacheFirst({
    cacheName: CACHE_NAME + 'google-fonts-webfonts',
    plugins: [
      new workbox.cacheableResponse.Plugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.Plugin({
        maxAgeSeconds: 60 * 60 * 24 * 365,
        maxEntries: 30,
      }),
    ],
  })
);

workbox.routing.registerRoute(
  /\.(?:js|css)$/,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE_NAME + 'static-resources',
  })
);

workbox.routing.registerRoute(
  /.+(png|jpg|jpeg|svg|gif)+.*/,
  // Use the cache if it's available.
  new workbox.strategies.CacheFirst({
    // Use a custom cache name.
    cacheName: CACHE_NAME,
    plugins: [
      new workbox.expiration.Plugin({
        // Cache only 20 images.
        maxEntries: 100,
        // Cache for a maximum of a week.
        maxAgeSeconds: 7 * 24 * 60 * 60,
      })
    ],
  })
);

workbox.routing.registerRoute(
  /.+(events\/)+.*/,
  // Use the cache if it's available.
  new workbox.strategies.NetworkFirst({
    // Use a custom cache name.
    cacheName: CACHE_NAME
  })
);

workbox.routing.registerRoute(
  /(.+\?+.*)|\/?/,
  // Use the cache if it's available.
  new workbox.strategies.NetworkFirst({
    // Use a custom cache name.
    cacheName: CACHE_NAME
  })
);

workbox.routing.registerRoute(
  '/',
  // Use the cache if it's available.
  new workbox.strategies.NetworkFirst({
    // Use a custom cache name.
    cacheName: CACHE_NAME
  })
);

