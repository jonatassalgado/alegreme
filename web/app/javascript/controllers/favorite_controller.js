
import { Controller } from "stimulus"
import { html, render } from 'lit-html';

export default class FavoriteController extends Controller {
  static targets = [ "list", "header", "event" ];

  initialize() {

  }

  showEventName(event) {
    const card = event.target.parentElement;
    card.querySelector(".mdc-typography--body2").style.display = "inline";
    card.addEventListener("mouseout", function() {
      this.querySelector(".mdc-typography--body2").style.display = "none";
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
            <div class="saved-list" data-target="favorite.list">
              <div class="mdc-layout-grid">
                <div class="mdc-layout-grid__inner">
                  ${events.map((event) => html `
                    <div class="mdc-layout-grid__cell mdc-layout-grid__cell--span-2" data-target="favorite.event" data-action="mouseover->favorite#showEventName mouseout->favorite#hideEventName">
                      <div class="me-card mdc-card">
                        <div class="mdc-card__media mdc-card__media--16-9" style="background-image: url('${event.cover_url}')">
                        </div>
                        <div class="mdc-typography--body2">
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
            <span>Você não possuí eventos salvos ainda</span>
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
