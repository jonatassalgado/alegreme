import { Controller } from "stimulus";
import { MDCMenu } from "@material/menu";
import { MDCRipple } from "@material/ripple";
import { CacheSystem } from "modules/cache-system";
import * as MobileDetect from "mobile-detect";
import * as mdc from "material-components-web";

export default class EventController extends Controller {
  static targets = [
    "event",
    "overlay",
    "name",
    "place",
    "date",
    "like",
    "likeButton",
    "likeCount",
    "moreButton",
    "menu"
  ];

  initialize() {
    const self = this;

    self.md = new MobileDetect(window.navigator.userAgent);

    self.activeInteractions = true;
    self.adjustForDevice = self.md.mobile();

    document.addEventListener("turbolinks:before-cache", () => {
      self.activeInteractions = false;
    });
  }

  showEventDetails() {
    const self = this;

    if (this.md.mobile()) {
    } else {
      if (self.data.get("favorited") == "false") {
        self.likeButtonTarget.style.display = "inline";
      }

      self.eventTarget.addEventListener("mouseout", function() {
        if (self.data.get("favorited") == "false") {
          self.likeButtonTarget.style.display = "none";
        }
      });
    }
  }

  openMenu() {
    const self = this;
    const mdcMenu = new MDCMenu(self.menuTarget);
    if (mdcMenu.open) {
      mdcMenu.open = false;
    } else {
      mdcMenu.open = true;
    }
  }

  like() {
    const self = this;

    Rails.ajax({
      type: self.isFavorited,
      url: `/events/${self.identifier}/favorite`,
      success: function(response) {
        self.activeLikeButton = response.currentEventFavorited;
        self.data.set("favorited", response.currentEventFavorited);

        if (self.favoriteController) {
          self.favoriteController.updateList = response.events;
        }

        CacheSystem.clearCache(["feed-page", "events-page"], {
          event: {
            identifier: self.identifier
          }
        });
      },
      error: function(response) {
        console.log(response);
      }
    });
  }

  get isFavorited() {
    if (this.data.get("favorited") == "true") {
      return "DELETE";
    } else {
      return "POST";
    }
  }

  get identifier() {
    return this.data.get("identifier");
  }

  get favoriteController() {
    return this.application.controllers.find(function(controller) {
      return controller.context.identifier === "favorite";
    });
  }

  set activeLikeButton(value) {
    const self = this; 
    document.querySelectorAll(`[data-event-identifier="${self.identifier}"]`).forEach((event) => {
      event.setAttribute('data-event-favorited', value);
      if (value) {
        event.querySelector('[data-target="event.likeButton"]').classList.add('mdc-icon-button--on')
      } else {
        event.querySelector('[data-target="event.likeButton"]').classList.remove('mdc-icon-button--on')
      }
    });
  }

  set likeCount(value) {
    const likeElementsCounts = document.querySelectorAll(
      `[data-event-identifier="${value.event_id}"] .me-like-count`
    );
    likeElementsCounts.forEach(count => {
      count.textContent = value.event_likes_count;
    });
  }

  set activeInteractions(value) {
    const self = this;

    if (value) {
      if (self.hasOverlayTarget && !self.overlayRipple) {
        self.overlayRipple = new MDCRipple(self.overlayTarget);
      }
      if (self.hasLikeButtonTarget) {
        self.toggleLikeButton = new mdc.iconButton.MDCIconButtonToggle(
          self.likeButtonTarget
        );
      }
    } else {
      if (self.overlayRipple) {
        self.overlayRipple.destroy();
      }
      if (self.likeButtonRipple) {
        self.likeButtonRipple.destroy();
      }
    }
  }

  set adjustForDevice(isMobile) {
    const self = this;
    const isFavorited = self.data.get("favorited") == "false";
    const isSingle = self.data.get("modifier") == "single";

    if (isMobile) {
    } else {
      if (isFavorited && !isSingle) {
        self.likeButtonTarget.style.display = "none";
      }
    }
  }
}
