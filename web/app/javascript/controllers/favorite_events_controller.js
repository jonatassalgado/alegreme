
import { Controller } from "stimulus"
import { html, render } from 'lit-html';

export default class FavoriteEventsController extends Controller {
  static targets = [ "event", "title", "date", "remove" ];

  initialize() {

  }


  showEventDetails(event) {
    const self = this;

    self.titleTarget.style.display = "inline";
    self.removeTarget.style.display = "inline";
    if (self.hasDateTarget) {
      self.dateTarget.style.display = "none";
    }

    self.eventTarget.addEventListener("mouseout", function() {
      self.titleTarget.style.display = "none";
      self.removeTarget.style.display = "none";
      if (self.hasDateTarget) {
        self.dateTarget.style.display = "inline";
      }
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
