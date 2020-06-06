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

		if (this.hasNavigationTarget) {
			this.lastScrollTop = 0;

			this.animateNavigationOnScroll = () => {
				var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
				if (window.scrollY > 250) {
					if (currentScrollTop > this.lastScrollTop){
						requestAnimationFrame(() => {
							this.navigationTarget.style.transform = 'translateY(60px)'
						});
					} else {
						requestAnimationFrame(() => {
							this.navigationTarget.style.transform = 'translateY(0)'
						});
					}
				} else {
					requestAnimationFrame(() => {
						this.navigationTarget.style.transform = 'translateY(0)'
					});
				}
				this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
			}

			window.addEventListener('scroll', this.animateNavigationOnScroll, {capture: false, passive: true});
		}

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
		window.removeEventListener('scroll', this.animateNavigationOnScroll, false);
	}

	goto(event) {
		const path = event.target.dataset.path;
		ProgressBarModule.show();
		setTimeout(() => {
			location.assign(path)
		}, 300);
	}

}
