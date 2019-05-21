import {
  Controller
} from "stimulus";
import * as MobileDetect from "mobile-detect";

export default class BotController extends Controller {
  static targets = [
    "bot",
    "start",
    "botIcon",
    "conversation",
    "reply",
    "close"
  ];

  initialize() {
    this.md = new MobileDetect(window.navigator.userAgent);

    if (this.hasInputTarget) {
      this.insertButton();
    }

    document.addEventListener("DOMContentLoaded", function () {
      var options = {
        id: gon.user_id || "null"
      };
      Botkit.boot(options);
    })
  }

  showBot() {
    this.conversationVisibility = "visible";
    this.overlayVisibility = "visible";
    this.heroVisibility = "hidden";
  }
  
  hideBot() {
    this.conversationVisibility = "hidden";
    this.overlayVisibility = "hidden";
  }

  insertButton() {}

  set overlayVisibility(value) {
    self = this;
    const overlay = document.querySelector(".me-overlay");

    switch (value) {
      case "visible":
        break;
      case "hidden":
    }
  }

  set heroVisibility(value) {
    self = this;

    switch (value) {
      case "visible":
        self.heroController.show();
        break;
      case "hidden":
        self.heroController.close();
        break;
    }
  }

  set conversationVisibility(value) {
    switch (value) {
      case "visible":

        this.botTarget.classList.add("me-bot--active");

        setTimeout(() => {
          if (this.data.get("already-open") == "false") {
            Botkit.send("Vamos", event);
            this.data.set("already-open", "true");
          }
        }, 400);
        break;
      case "hidden":


        this.botTarget.classList.remove("me-bot--active");

        break;
    }
  }

  get heroController() {
    return this.application.controllers.find(function (controller) {
      return controller.context.identifier === "hero";
    });
  }
}