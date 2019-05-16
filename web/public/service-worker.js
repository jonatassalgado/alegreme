importScripts('https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js');

var CACHE_VERSION = 'v1';
var CACHE_NAME = CACHE_VERSION + ':sw-cache-';


workbox.routing.registerRoute(
  /^https:\/\/fonts\.googleapis\.com/,
  new workbox.strategies.CacheFirst({
    cacheName: CACHE_NAME + 'google-fonts-stylesheets',
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
  /.+(?:js|css)+.*$/,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE_NAME + 'static-resources',
  })
);

workbox.routing.registerRoute(
  /.+(png|jpg|jpeg|svg|gif)+.*/,
  new workbox.strategies.CacheFirst({
    cacheName: CACHE_NAME + 'static-images',
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
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE_NAME + 'events-page'
  })
);

workbox.routing.registerRoute(
  /(\/|\/#)/,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE_NAME + 'feed-page'
  })
);

workbox.routing.registerRoute(
  /.+(\?(categories\[\]|ocurrences\[\]|personas\[\])+.*)|\/?$/,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE_NAME + 'filters-page'
  })
);




