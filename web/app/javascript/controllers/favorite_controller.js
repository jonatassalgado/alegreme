
import { Controller } from "stimulus"
import { html, render } from 'lit-html';

export default class FavoriteController extends Controller {
  static targets = [ "event", "list", "title", "date", "scrollLeft", "scrollRight", "header" ];

  initialize() {

  }

  scrollLeft(event) {
    const amount = this.listTarget.offsetWidth * -1;
    this.listTarget.scrollBy(amount, 0);
  }

  scrollRight(event) {
    const amount = this.listTarget.offsetWidth;
    this.listTarget.scrollBy(amount, 0);
  }

  showEventName(event) {
    const self = event.target;
    const parent = event.target.parentElement;

    parent.querySelector('.me-card__title').style.display = "inline";
    parent.querySelector('.me-card__date').style.display = "none";

    self.addEventListener("mouseout", function() {
      parent.querySelector('.me-card__title').style.display = "none";
      parent.querySelector('.me-card__date').style.display = "inline";
    })
  }

  set updateList(events) {

    const favoriteTemplate = (events) =>
      html`
        ${events.length > 0
          ? html `
            <h2 data-target="favorite.header" class="mdc-typography--headline2">
              Eventos salvos
            </h2>
            <div class="me-icon__group">
              <div data-target="favorite.scrollLeft" data-action="click->favorite#scrollLeft" class="me-icon me-icon--scroll-left">
                <svg viewBox="0 0 24 24" preserveAspectRatio="xMidYMid meet" focusable="false" class="style-scope iron-icon" style="pointer-events: none; display: block; width: 100%; height: 100%;"><g class="style-scope iron-icon"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" class="style-scope iron-icon"></path></g></svg>
              </div>
              <div data-target="favorite.scrollRight" data-action="click->favorite#scrollRight" class="me-icon me-icon--scroll-right">
                <svg viewBox="0 0 24 24" preserveAspectRatio="xMidYMid meet" focusable="false" class="style-scope iron-icon" style="pointer-events: none; display: block; width: 100%; height: 100%;"><g class="style-scope iron-icon"><path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z" class="style-scope iron-icon"></path></g></svg>
              </div>
            </div>
            <div class="saved-list">
              <div class="mdc-layout-grid">
                <div data-target="favorite.list" class="mdc-layout-grid__inner">
                  ${events.map((event) => html `
                    <div class="mdc-layout-grid__cell mdc-layout-grid__cell--span-2">
                      <div class="me-card mdc-card event-${event.id}" data-target="favorite.event" data-action="mouseover->favorite#showEventName">
                        <div class="mdc-card__media mdc-card__media--16-9" style="background-image: url('${event.cover_url}')">
                        </div>
                        <div class="me-card__date" data-target="favorite.date">
                          ${event.day_of_week}
                        </div>
                        <div class="me-card__title mdc-card__title" data-target="favorite.title" style="display: none">
                          <a href="${event.url}">
                            <span>${event.name}</span>
                          </a>
                        </div>
                      </div>
                    </div>
                    `
                  )}
                </div>
              </div>
            </div>
            `
          : html `
            <h2 class="mdc-typography--headline2">
              Você não possuí eventos salvos ainda
            </h2>
          `
        }
      `;

    const favoriteWrapper = document.querySelector('.me-favorite')

    render(favoriteTemplate(events), favoriteWrapper);

  }

  get favoriteHeader() {
    return this.headerTarget
  }

}
