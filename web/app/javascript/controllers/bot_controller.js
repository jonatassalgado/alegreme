import { Controller } from "stimulus";
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
  }

  showBot() {
    this.conversationVisibility = "visible";
    this.overlayVisibility = "visible";
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
        // overlay.classList.add("me-overlay--active");
        // overlay.addEventListener("click", function() {
        //   self.conversationVisibility = "hidden";
        //   self.overlayVisibility = "hidden";
        // });
        break;
      case "hidden":
        // overlay.classList.remove("me-overlay--active");
        // break;
    }
  }

  set conversationVisibility(value) {
    switch (value) {
      case "visible":
        // if (!this.md.mobile() && this.hasReplyTarget) {
        //   this.replyTarget.style.display = "none";
        // }
        // this.conversationTarget.style.visibility = "visible";
        // this.conversationTarget.style.opacity = 1;
        this.botTarget.classList.add("me-bot--active");

        // this.botTarget.parentElement.classList.add("me-top-app-bar--bot-on");
        // document.body.style.overflow = "hidden";
        setTimeout(() => {
          if (this.data.get("already-open") == "false") {
            Botkit.send("Vamos", event);
            this.data.set("already-open", "true");
          }
        //   this.closeTarget.classList.add("me-bot__close--bot-on");
        }, 400);
        break;
      case "hidden":
        // if (!this.md.mobile() && this.hasReplyTarget) {
        //   this.replyTarget.style.display = "block";
        // }
        // document.body.style.overflow = "";
        // this.conversationTarget.style.visibility = "hidden";
        // this.conversationTarget.style.opacity = 0;

        this.botTarget.classList.remove("me-bot--active");
        // this.botTarget.parentElement.classList.remove("me-top-app-bar--bot-on");
        // this.closeTarget.classList.remove("me-bot__close--bot-on");
        break;
    }
  }
}
