import { Controller } from "stimulus"


export default class SnackbarController extends Controller {
  static targets = [];

  initialize() {
    caches.open('v1:sw-cache-feed-page').then(function(cache) {
      cache.delete('/').then(function(response) {
        if (response) {
          cache.add('/');
        } 
      });
    })
  }

}
