
import { Controller } from "stimulus"
import { html, render } from 'lit-html';

export default class SearchFieldController extends Controller {
  static targets = [ "chat", "field", "input", "botIcon", "botConversation", "reply" ];

  initialize() {
    if (this.hasInputTarget) {
      this.insertButton();
    }
  }


  showBot(event) {
    this.overlayVisibility = 'visible';
    this.conversationVisibility = 'visible';
  }


  insertButton(event) {
    const textSize = this.inputTarget.placeholder.length;
    const buttonDistance = (textSize * 12) + 'px';

    if (this.hasReplyTarget) {
      this.replyTarget.style.display = 'block';
      this.replyTarget.style.left = buttonDistance;
    }
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
        break;
      case 'hidden':
        if (this.hasReplyTarget) { this.replyTarget.style.display = 'block' }
        this.botConversationTarget.style.visibility = 'hidden';
        this.botConversationTarget.style.opacity = 0;
        this.fieldTarget.classList.remove("me-search-field--bot-on");
        break;
    }
  }

}
