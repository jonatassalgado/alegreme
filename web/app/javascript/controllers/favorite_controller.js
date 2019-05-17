
import { Controller } from "stimulus"
import { html, render } from 'lit-html';

export default class FavoriteController extends Controller {
  static targets = [ "event", "list", "title", "date", "remove", "scrollLeft", "scrollRight", "header" ];

  initialize() {
    if (this.hasListTarget) {
      this.removeRepeatedDates = true;
      this.hideScrollButtons = true;
    }
  }


  scrollLeft(event) {
    const amount = this.listTarget.offsetWidth * -1;
    this.listTarget.scrollBy(amount, 0);
  }


  scrollRight(event) {
    const amount = this.listTarget.offsetWidth;
    this.listTarget.scrollBy(amount, 0);
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
      <div data-target="favorite.list" class="me-favorite__list mdc-layout-grid">
        <div class="mdc-layout-grid__inner">
        ${events.map((event) => html `
          <div class="mdc-layout-grid__cell mdc-layout-grid__cell--span-2">
            <div data-controller="favorite-events" data-target="favorite-events.event" data-action="mouseover->favorite-events#showEventDetails" class="me-card mdc-card event-${event.id}" data-favorite-events-identifier="${event.id}">
              <div data-target="favorite-events.remove" data-action="click->favorite-events#remove" class="me-card__remove">
                <svg viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet" focusable="false"><path d="m55.7 52.7c6.2 6.7 12.4 13.5 18.6 20.2 2.2 2.4-1.4 5.9-3.5 3.5-6.2-6.7-12.3-13.4-18.5-20.1-6.1 6.8-12.3 13.4-18.4 20.1-2.2 2.4-5.7-1.2-3.5-3.5 6.2-6.7 12.4-13.5 18.6-20.2-6.2-6.7-12.4-13.5-18.6-20.2-2.2-2.4 1.4-5.9 3.5-3.5 6.1 6.6 12.3 13.3 18.4 20 6.2-6.7 12.3-13.4 18.5-20.1 2.2-2.4 5.7 1.2 3.5 3.5-6.2 6.8-12.4 13.5-18.6 20.3z"/></svg>
              </div>
              <a href="${event.url}">
                <div class="mdc-card__media mdc-card__media--16-9" style="background-image: url('${event.cover_url}')">
                <div data-target="favorite-events.overlay" class="me-card__overlay mdc-ripple-surface	"></div>
                </div>
                <div class="me-card__date" data-target="favorite-events.date">
                  ${event.day_of_week}
                </div>
                <div class="me-card__title mdc-card__title" data-target="favorite-events.title">
                    <span>${event.name}</span>
                </div>
              </a>
            </div>
          </div>
          `
        )}
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

    this.removeRepeatedDates = true;
    this.hideScrollButtons = true;
    
  }


  get favoriteHeader() {
    return this.headerTarget
  }


  set removeRepeatedDates(value) {
    if (value == true) {
      const dates = document.querySelectorAll('.me-favorite .me-card__date');
      var lastDay = dates[0].innerText;
      for(var i = 0; i < dates.length - 1; i++){
        if (lastDay != dates[i+1].innerText) {
          lastDay = dates[i].innerText;
        }
        if(lastDay == dates[i+1].innerText) {
          dates[i+1].remove()
        }
      }
    }
  }


  set hideScrollButtons(value) {
    const self = this;
    const hideScroll = hideScroll;

    if (value == true) {
      hideScroll();
      self.listTarget.addEventListener('scroll', hideScroll)
    }

    function hideScroll() {
      var parentSize = self.listTarget.offsetParent.offsetWidth;
      var scrollSize = self.listTarget.scrollWidth;
      var scrolled = self.listTarget.scrollLeft;

      if(parentSize + scrolled >= scrollSize) {
        self.scrollRightTarget.classList.add('me-icon--off');
        self.listTarget.classList.remove('me-favorite__list--at-end');
      }
      else if (scrolled == 0) {
        self.scrollLeftTarget.classList.add('me-icon--off');
        self.listTarget.classList.add('me-favorite__list--at-end');
        self.listTarget.classList.remove('me-favorite__list--at-initital');
      }
      else {
        self.listTarget.classList.add('me-favorite__list--at-initital');
        self.scrollLeftTarget.classList.remove('me-icon--off');
        self.scrollRightTarget.classList.remove('me-icon--off');
      }
    }
  }

}
