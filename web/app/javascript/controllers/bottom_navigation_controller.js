import ApplicationController from './application_controller'
import {MDCRipple}           from '@material/ripple';
import {AnimateModule}       from "../modules/animate-module";

export default class BottomNavigationController extends ApplicationController {
	static targets = ['navigation', 'item', 'events', 'search', 'cinema'];

	connect() {
		this.ripples = [];

		this.itemTargets.forEach((item) => {
			this.ripples.push(new MDCRipple(item));
		});

		if (this.hasNavigationTarget) {
			this.lastScrollTop = 0;

			this.animateNavigationOnScroll = () => {
				var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
				if (window.scrollY > 250) {
					if (currentScrollTop > this.lastScrollTop) {
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

			window.addEventListener('scroll', this.animateNavigationOnScroll, {
				capture: false,
				passive: true
			});
		}


		if (/(\/feed|\/porto-alegre\/eventos)/.test(document.location.href)) {
			this.eventsTarget.classList.add('active');
		} else if ((/(\/porto-alegre\/filmes)/.test(document.location.href)) ||
			(/(\/porto-alegre\/streamings)/.test(document.location.href))) {
			this.cinemaTarget.classList.add('active');
		} else if ((/(\/busca)/.test(document.location.href))) {
			this.searchTarget.classList.add('active');
			document.querySelector('.mdc-text-field__input').focus();
		}


	}

	disconnect() {
		window.removeEventListener('scroll', this.animateNavigationOnScroll, false);
		this.ripples.forEach((ripple) => {
			ripple.destroy();
		});
		this.itemTargets.forEach((item, i) => {
			item.classList.remove('active');
		});
	}

	goto(event) {
		AnimateModule.animatePageHide();

		const unactiveItemsPromise = new Promise((resolve, reject) => {
			this.itemTargets.forEach((item, i) => {
				item.classList.remove('active');
			});
			resolve();
		})

		unactiveItemsPromise.then(() => {
			event.target.classList.add('active');
		})

		const path = event.target.dataset.path;
		setTimeout(() => {
			Turbolinks.visit(path)
		}, 250)
	}

}
