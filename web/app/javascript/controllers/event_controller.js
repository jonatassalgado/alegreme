import { Controller } from "stimulus"
import { html, render } from 'lit-html';


export default class EventController extends Controller {
  static targets = [ "event", "name", "place", "date", "like", "likeButton", "likeCount" ];

  initialize() {

  }

  showEventPlace(event) {
    const self = this

    self.nameTarget.style.display = "none";
    self.placeTarget.style.display = "inline";
    self.dateTarget.style.display = "inline";

    self.eventTarget.addEventListener("mouseout", function() {
      self.nameTarget.style.display = "inline";
      self.placeTarget.style.display = "none";
      self.dateTarget.style.display = "none";
    })
  }


  like() {
    const self = this

    Rails.ajax({
      type: self.isFavorited,
      url: `/events/${self.identifier}/favorite`,
      success: function(response){
        // self.likeCount = response
        self.likeActive = response
        self.data.set("favorited", response.favorited)
        self.favoriteController.updateList = response.all_favorited
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


  set likeActive(value) {
    const like = (favorite) =>
      html `
        ${ favorite ?
          html `
            <i class="material-icons mdc-button__icon">star</i>
            <span class="mdc-button__label" style="text-align: right">
              Salvo
            </span>
          `

          :

          html `
            <i class="material-icons mdc-button__icon">star</i>
            <span class="mdc-button__label" style="text-align: right">
              Salvar
            </span>
          `
        }
      `;

    const likeButtonsWrapper = this.likeButtonTarget;
    likeButtonsWrapper.classList.toggle('mdc-button--raised');

    render(like(value.favorited), likeButtonsWrapper);
  }

}
