import ApplicationController from './application_controller'

export default class SnackbarController extends ApplicationController {
	static targets = [];

	initialize() {
		// CacheModule.clearCache();

		// caches.open('v1:sw-cache-feed-page').then(function(cache) {
		//   cache.delete('/').then(function(response) {
		//     if (response) {
		//       cache.add('/');
		//     }
		//   });
		// });
	}

}
