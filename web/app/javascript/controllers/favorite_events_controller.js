import { Controller } from "stimulus"
import {MDCRipple} from '@material/ripple';


export default class FavoriteEventsController extends Controller {
  static targets = [ "event", "overlay", "title", "date", "remove" ];

  initialize() {
    if (this.hasOverlayTarget) {
      MDCRipple.attachTo(this.overlayTarget);
    }
  }


  showEventDetails(event) {
    const self = this;

    self.removeTarget.style.display = "inline";
    self.eventTarget.addEventListener("mouseout", function() {
      self.removeTarget.style.display = "none";
    })
  }


  remove() {
    const self = this

    Rails.ajax({
      type: "DELETE",
      url: `/events/${self.identifier}/favorite`,
      success: function(response){
        
        document.querySelectorAll(`[data-event-identifier="${self.identifier}"]`).forEach((event) => {
          event.setAttribute('data-event-favorited', false);
          event.querySelector('[data-target="event.likeButton"]').classList.remove('mdc-icon-button--on')
        });

        if (self.favoriteController) {
          self.favoriteController.updateList = response.all_favorited
        }
      },
      error: function(response){
        console.log(response)
      }
    })
  }


  get favoriteController() {
    return this.application.controllers.find(function(controller) {
      return controller.context.identifier === 'favorite'
    })
  }


  get identifier() {
    return this.data.get("identifier")
  }


}
