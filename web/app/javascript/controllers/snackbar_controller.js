import { Controller } from "stimulus";
import {CacheSystem} from "modules/cache-system";


export default class SnackbarController extends Controller {
  static targets = [];

  initialize() {
    CacheSystem.clearCache();
    
    caches.open('v1:sw-cache-feed-page').then(function(cache) {
      cache.delete('/').then(function(response) {
        if (response) {
          cache.add('/');
        } 
      });
    });
  }

}
