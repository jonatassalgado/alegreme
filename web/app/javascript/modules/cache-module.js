import * as Turbolinks from "turbolinks";

const CacheModule = (function () {
	const module = {};
	const status = {
		turbolinksStarted: false
	};

	const startTurbolinks = () => {
		Turbolinks.start();
		Turbolinks.setProgressBarDelay(500);
		status.turbolinksStarted = true;
		console.log("[TURBOLINKS]: started");
	};

	module.activateTurbolinks = () => {
		if (navigator.serviceWorker && !caches.has("v1:sw-cache-feed-page")) {
			caches.open("v1:sw-cache-feed-page")
			.then(cache => {
				cache.add('/feed').then(() => {
					console.log("Cache v1:sw-cache-feed-page updated");
				})
			})
			.catch(reason => {
				console.log(reason);
			});
		}


		// const feedCache = caches.has("v1:sw-cache-feed-page");
		// const staticResourcesCache = caches.has("v1:sw-cache-static-resources");
		// const staticImagesCache = caches.has("v1:sw-cache-static-images");
		// const gFontsCache = caches.has("v1:sw-cache-google-fonts-stylesheets");
		// // const wFontsCache = caches.has("v1:sw-cache-google-fonts-webfonts");
		//
		// Promise.all([
		//   feedCache,
		//   staticResourcesCache,
		//   staticImagesCache,
		//   gFontsCache
		//   // wFontsCache
		// ])
		//   .then(hasCaches => {
		//     const hasCachedPrincipalResources = hasCaches.every(Boolean);
		//     if (hasCachedPrincipalResources) {
			    startTurbolinks();
		  //   }
		  // })
		  // .catch(reason => {
		  //   console.log(reason.message);
		  // });
	};

	module.clearCache = (cacheNames, attrs) => {
		// if (navigator.serviceWorker && !cacheNames || cacheNames.includes("feed-page")) {
		// 	caches.open("v1:sw-cache-feed-page")
		// 	      .then(cache => {
		// 		      cache
		// 			      .delete("/feed")
		// 			      .then(response => {
		// 				      if (response) {
		// 					      console.log("Cache v1:sw-cache-feed-page deleted: ", response);
		// 				      }
		// 				      // cache.add('/feed').then(() => {
        //                       //   console.log("Cache v1:sw-cache-feed-page updated: ");
		// 				      // })
		// 			      });
		// 	      })
		// 	      .catch(reason => {
		// 		      console.log(reason);
		// 	      });
		// }
		//
		// if (navigator.serviceWorker && cacheNames && cacheNames.includes("events-page")) {
		// 	caches
		// 		.open("v1:sw-cache-events-page")
		// 		.then(cache => {
		// 			cache
		// 				.delete(`/porto-alegre/eventos/${attrs.event.identifier}`)
		// 				.then(response => {
		// 					if (response) {
		// 						console.log("v1:sw-cache-events-page deleted: ", response);
		// 						// cache.add(`/events/${attrs.event.identifier}`);
		// 					}
		// 				});
		// 		})
		// 		.catch(reason => {
		// 			console.log(reason);
		// 		});
		// }

		if (status.turbolinksStarted) {
			Turbolinks.clearCache();
			console.log("[TURBOLINKS] cache cleaned: true");
		}
	};

	window.CacheModule = module;

	return module;
})();

export {CacheModule};
