import { Controller } from "stimulus";
import {CacheModule} from "modules/cache-module";


export default class SnackbarController extends Controller {
  static targets = [];

  initialize() {
    // CacheModule.clearCache();
    
    caches.open('v1:sw-cache-feed-page').then(function(cache) {
      cache.delete('/').then(function(response) {
        if (response) {
          cache.add('/');
        } 
      });
    });
  }

}
