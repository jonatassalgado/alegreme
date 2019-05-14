import { Controller } from "stimulus"
import {MDCMenu} from '@material/menu';
import * as MobileDetect from 'mobile-detect';



export default class EventController extends Controller {
  static targets = [ "event", "overlay", "name", "place", "date", "like", "likeButton", "likeCount", "moreButton", "menu" ];

  initialize() {
    this.md = new MobileDetect(window.navigator.userAgent);

    if (this.md.mobile()) {

    } else {
      if (this.data.get('favorited') == 'false') {
        this.likeButtonTarget.style.display = "none";
      }
    }
  }

  showEventDetails() {
    const self = this

    if (this.md.mobile()) {
      
    } else {
      if (self.data.get('favorited') == 'false') {
        self.likeButtonTarget.style.display = "inline";
      }
  
      self.eventTarget.addEventListener("mouseout", function() {
        if (self.data.get('favorited') == 'false') {
          self.likeButtonTarget.style.display = "none";
        }
      })  
    }
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

        // Turbolinks.clearCache();
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
