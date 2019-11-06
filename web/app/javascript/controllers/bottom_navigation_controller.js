import {Controller} from "stimulus";
import {MDCRipple}  from '@material/ripple';

export default class BottomNavigationController extends Controller {
	static targets = ['navigation', 'item', 'home', 'search', 'explore'];

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

    if (/(\/feed)/.test(document.location.href)) {
      this.homeTarget.classList.add('active');
    } else if ((/(\/porto-alegre)/.test(document.location.href))){
      this.exploreTarget.classList.add('active');
    }

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

  goto(event) {
    const path = event.target.dataset.path;
    window.Turbolinks.visit(path);
  }

}
