importScripts("https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js");


self.addEventListener('push', function (event) {
    // Extract payload as JSON object, default to empty object
    var data  = event.data.json() || {};
    var image = data.image;
    var badge = data.badge;

    var title   = data.title || '';
    var body    = data.message || '';
    var actions = data.actions ? JSON.parse(data.actions) : [];

    // Notification options
    var options = {
        body:    body,
        icon:    image,
        badge:   badge,
        actions: actions,
        data:    {
            url: data.url
        }
    };

    event.waitUntil(self.registration.showNotification(title, options));
});

// Listen for notification click event
self.addEventListener('notificationclick', function (event) {
    event.notification.close();
    var url = event.notification.data.url;

    if (event.action === 'open-app') {
        event.waitUntil(clients.openWindow(url));
    } else {
        event.waitUntil(clients.openWindow(url));
    }
});


var CACHE_VERSION = "v1";
var CACHE_NAME    = CACHE_VERSION + ":sw-cache-";

workbox.setConfig({debug: false})


workbox.routing.registerRoute(
    "/",
    new workbox.strategies.NetworkFirst({
                                            cacheName: CACHE_NAME + "root-page",
                                            plugins:   [
                                                new workbox.expiration.Plugin({
                                                                                  maxEntries:    5,
                                                                                  maxAgeSeconds: 2 * 24 * 60 * 60
                                                                              })
                                            ]
                                        })
);


workbox.routing.registerRoute(
    /^https:\/\/fonts\.googleapis\.com/,
    new workbox.strategies.CacheFirst({
                                          cacheName: CACHE_NAME + "google-fonts-stylesheets",
                                          plugins:   [
                                              new workbox.cacheableResponse.Plugin({
                                                                                       statuses: [0, 200]
                                                                                   }),
                                              new workbox.expiration.Plugin({
                                                                                maxAgeSeconds: 60 * 60 * 24 * 365,
                                                                                maxEntries:    10
                                                                            })
                                          ]
                                      })
);

workbox.routing.registerRoute(
    /^https:\/\/fonts\.gstatic\.com/,
    new workbox.strategies.CacheFirst({
                                          cacheName: CACHE_NAME + "google-fonts-webfonts",
                                          plugins:   [
                                              new workbox.cacheableResponse.Plugin({
                                                                                       statuses: [0, 200]
                                                                                   }),
                                              new workbox.expiration.Plugin({
                                                                                maxAgeSeconds: 60 * 60 * 24 * 365,
                                                                                maxEntries:    10
                                                                            })
                                          ]
                                      })
);

workbox.routing.registerRoute(
    /.+(?:js|css)+.*$/,
    new workbox.strategies.CacheFirst({
                                          cacheName: CACHE_NAME + "static-resources",
                                          plugins:   [
                                              new workbox.expiration.Plugin({
                                                                                maxEntries:    20,
                                                                                maxAgeSeconds: 2 * 24 * 60 * 60
                                                                            })
                                          ]
                                      })
);

workbox.routing.registerRoute(
    /^https:\/\/alegreme\.sfo2\.digitaloceanspaces\.com\/store/,
    new workbox.strategies.CacheFirst({
                                          cacheName: CACHE_NAME + "static-images",
                                          plugins:   [
                                              new workbox.cacheableResponse.Plugin({
                                                                                       statuses: [0, 200]
                                                                                   }),
                                              new workbox.expiration.Plugin({
                                                                                // Cache only 20 images.
                                                                                maxEntries:    30,
                                                                                // Cache for a maximum of a week.
                                                                                maxAgeSeconds: 2 * 24 * 60 * 60
                                                                            })
                                          ]
                                      })
);

workbox.routing.registerRoute(
    /.+(porto-alegre\/eventos\/)+.*/,
    new workbox.strategies.NetworkFirst({
                                            cacheName: CACHE_NAME + "events-page",
                                            plugins:   [
                                                new workbox.expiration.Plugin({
                                                                                  maxEntries:    30,
                                                                                  maxAgeSeconds: 2 * 24 * 60 * 60
                                                                              })
                                            ]
                                        })
);

workbox.routing.registerRoute(
    /.+(porto-alegre\/(filmes|streamings)\/)+.*/,
    new workbox.strategies.NetworkFirst({
                                            cacheName: CACHE_NAME + "movies-page",
                                            plugins:   [
                                                new workbox.expiration.Plugin({
                                                                                  maxEntries:    10,
                                                                                  maxAgeSeconds: 2 * 24 * 60 * 60
                                                                              })
                                            ]
                                        })
);

workbox.routing.registerRoute(
    /.+\/(feed|porto-alegre\/filmes)/,
    new workbox.strategies.NetworkFirst({
                                            cacheName: CACHE_NAME + "feed-page",
                                            plugins:   [
                                                new workbox.expiration.Plugin({
                                                                                  maxEntries:    10,
                                                                                  maxAgeSeconds: 2 * 24 * 60 * 60
                                                                              })
                                            ]
                                        })
);

workbox.routing.registerRoute(
    /.+(\?(categories\[\]|ocurrences\[\]|personas\[\])+.*)|\/?$/,
    new workbox.strategies.NetworkFirst({
                                            cacheName: CACHE_NAME + "filters-page",
                                            plugins:   [
                                                new workbox.expiration.Plugin({
                                                                                  maxEntries:    10,
                                                                                  maxAgeSeconds: 2 * 24 * 60 * 60
                                                                              })
                                            ]
                                        })
);
