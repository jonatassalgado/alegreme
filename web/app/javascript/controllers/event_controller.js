import { Controller } from "stimulus"
import { html, render } from 'lit-html';
import { iconButton } from 'material-components-web';
import {MDCMenu} from '@material/menu';



export default class EventController extends Controller {
  static targets = [ "event", "name", "place", "date", "like", "likeButton", "likeCount", "moreButton", "menu" ];

  initialize() {
    // new MDCMenu(this.moreButtonTarget);
  }

  showEventDetails() {
    const self = this

    self.nameTarget.style.display = "none";
    self.placeTarget.style.display = "inline";
    self.dateTarget.style.display = "inline";
    self.likeButtonTarget.style.display = "inline";

    self.eventTarget.addEventListener("mouseout", function() {
      self.nameTarget.style.display = "inline";
      self.placeTarget.style.display = "none";
      self.dateTarget.style.display = "none";
      self.likeButtonTarget.style.display = "none";
    })
  }

  openMenu() {
    const self = this;
    console.log(MDCMenu);
    console.log(self.menuTarget);
    const mdcMenu = new MDCMenu(self.menuTarget);
    if (mdcMenu.open) {
      mdcMenu.open = false;
    } else {
      mdcMenu.open = true;
    }
  }

  like() {
    const self = this

    Rails.ajax({
      type: self.isFavorited,
      url: `/events/${self.identifier}/favorite`,
      success: function(response){
        self.data.set("favorited", response.favorited)
        if (self.favoriteController) {
          self.favoriteController.updateList = response.all_favorited
        }
      },
      error: function(response){
        console.log(response)
      }
    })
  }


  get isFavorited() {
    if (this.data.get("favorited") == "true") {
      return "DELETE"
    } else {
      return "POST"
    }
  }


  get identifier() {
    return this.data.get("identifier")
  }


  get favoriteController() {
    return this.application.controllers.find(function(controller) {
      return controller.context.identifier === 'favorite'
    })
  }


  set likeCount(value) {
    const likeElementsCounts = document.querySelectorAll(`[data-event-identifier="${value.event_id}"] .me-like-count`)
    likeElementsCounts.forEach( count => { count.textContent = value.event_likes_count } )
  }


}
