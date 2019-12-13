import {Controller}        from "stimulus";
import {MDCRipple}         from '@material/ripple';
import {ProgressBarModule} from "../modules/progressbar-module";

export default class BottomNavigationController extends Controller {
	static targets = ['navigation', 'item', 'events', 'search', 'cinema'];

	initialize() {
		this.ripples = [];

		this.itemTargets.forEach((item) => {
			this.ripples.push(new MDCRipple(item));
		});

		this.destroy = () => {
			this.ripples.forEach((ripple) => {
				ripple.destroy();
			});
		};


		if (/(\/feed|\/porto-alegre\/eventos)/.test(document.location.href)) {
			this.eventsTarget.classList.add('active');
		} else if ((/(\/porto-alegre\/cinema)/.test(document.location.href))) {
			this.cinemaTarget.classList.add('active');
		} else if ((/(\/busca)/.test(document.location.href))) {
			this.searchTarget.classList.add('active');
			document.querySelector('.mdc-text-field__input').focus();
		}

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	goto(event) {
		const path = event.target.dataset.path;
		ProgressBarModule.show();
		setTimeout(() => {
			location.assign(path)
		}, 300);
	}

}
