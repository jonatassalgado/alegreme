
import { Controller } from "stimulus"
import { html, render } from 'lit-html';

export default class SearchFieldController extends Controller {
  static targets = [ "chat", "field", "form", "input", "botIcon", "botConversation", "reply", "close" ];

  initialize() {
    if (this.hasInputTarget) {
      this.insertButton();
    }
  }


  showBot() {
    this.conversationVisibility = 'visible';
    this.overlayVisibility = 'visible';
  }


  hideBot() {
    this.conversationVisibility = 'hidden';
    this.overlayVisibility = 'hidden';
  }


  insertButton() {
    // const textSize = this.inputTarget.placeholder.length;
    // const buttonDistance = (textSize * 12) + 'px';

    // if (this.hasReplyTarget) {
    //   this.replyTarget.style.display = 'block';
    //   this.replyTarget.style.left = buttonDistance;
    // }
  }


  search(event) {
    console.log(event);
    event.preventDefault();

    const query = this.inputTarget.value;
    // Turbolinks.visit(`${location.origin}?q=${query.toLowerCase()}`);
    location.assign(`${location.origin}?q=${query.toLowerCase()}`);
  }


  set overlayVisibility(value) {
    self = this;
    const overlay = document.querySelector('.me-overlay');

    switch (value) {
      case 'visible':
        overlay.classList.add("me-overlay--active");
        overlay.addEventListener("click", function() {
          self.conversationVisibility = 'hidden';
          self.overlayVisibility = 'hidden';
        })
        break;
      case 'hidden':
        overlay.classList.remove("me-overlay--active");
        break;
    }
  }


  set conversationVisibility(value) {
    switch (value) {
      case 'visible':
        if (this.hasReplyTarget) { this.replyTarget.style.display = 'none' }
        this.botConversationTarget.style.visibility = 'visible';
        this.botConversationTarget.style.opacity = 1;
        this.fieldTarget.classList.add("me-search-field--bot-on");
        this.fieldTarget.parentElement.classList.add("me-top-app-bar--bot-on");
        setTimeout(() => {
          this.closeTarget.classList.add("me-search-field__close--bot-on");
        }, 400)
        break;
        case 'hidden':
        if (this.hasReplyTarget) { this.replyTarget.style.display = 'block' }
        this.botConversationTarget.style.visibility = 'hidden';
        this.botConversationTarget.style.opacity = 0;
        this.fieldTarget.classList.remove("me-search-field--bot-on");
        this.fieldTarget.parentElement.classList.remove("me-top-app-bar--bot-on");
        this.closeTarget.classList.remove("me-search-field__close--bot-on");
        break;
    }
  }

}
