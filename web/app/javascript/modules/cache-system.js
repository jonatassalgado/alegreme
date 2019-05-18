import * as Turbolinks from "turbolinks";

const CacheSystem = (function() {
  const module = {};
  const status = {
    turbolinksStarted: false
  };

  const startTurbolinks = () => {
    Turbolinks.start();
    status.turbolinksStarted = true;
    console.log("[TURBOLINKS]: started");
  };

  module.activateTurbolinks = () => {
    const feedCache = caches.has("v1:sw-cache-feed-page");
    const staticResourcesCache = caches.has("v1:sw-cache-static-resources");
    const staticImagesCache = caches.has("v1:sw-cache-static-images");
    const gFontsCache = caches.has("v1:sw-cache-google-fonts-stylesheets");
    const wFontsCache = caches.has("v1:sw-cache-google-fonts-webfonts");

    Promise.all([
      feedCache,
      staticResourcesCache,
      staticImagesCache,
      gFontsCache,
      wFontsCache
    ])
      .then(hasCaches => {
        const hasCachedPrincipalResources = hasCaches.every(Boolean);
        if (hasCachedPrincipalResources) {
          startTurbolinks();
        }
      })
      .catch(reason => {
        console.log(reason.message);
      });
  };

  module.clearCache = (cacheNames, attrs) => {
    if (!cacheNames || cacheNames.includes("feed-page")) {
      caches
        .open("v1:sw-cache-feed-page")
        .then(function(cache) {
          cache.delete("/").then(function(response) {
            if (response) {
              console.log("Cache v1:sw-cache-feed-page deleted: ", response);
            }
          });
        })
        .catch(function(reason) {
          console.log(reason);
        });
    }

    if (cacheNames && cacheNames.includes("events-page")) {
      caches
        .open("v1:sw-cache-events-page")
        .then(function(cache) {
          cache
            .delete(`/events/${attrs.event.identifier}`)
            .then(function(response) {
              if (response) {
                console.log("v1:sw-cache-events-page deleted: ", response);
                // cache.add(`/events/${attrs.event.identifier}`);
              }
            });
        })
        .catch(function(reason) {
          console.log(reason);
        });
    }

    if (status.turbolinksStarted) {
      Turbolinks.clearCache();
      console.log("[TURBOLINKS] cache cleaned: true");
    }
  };

  window.CacheSystem = module;

  return module;
})();

export { CacheSystem };
