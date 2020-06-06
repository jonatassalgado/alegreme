import {Controller} from 'stimulus';

export default class HeadController extends Controller {
	static targets = ['head'];

	initialize() {
		if (this.hasHeadTarget) {
			this.lastScrollTop = 0;

			this.animateHeadOnScroll = () => {
				var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
				if (window.scrollY > 250) {
					if (currentScrollTop > this.lastScrollTop){
						requestAnimationFrame(() => {
							this.headTarget.style.transform = 'translateY(-50px)'
						});
					} else {
						requestAnimationFrame(() => {
							this.headTarget.style.transform = 'translateY(0)'
						});
					}
				} else {
					requestAnimationFrame(() => {
						this.headTarget.style.transform = 'translateY(0)'
					});
				}
				this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
			}

			window.addEventListener('scroll', this.animateHeadOnScroll, {capture: false, passive: true});
		}
	}

	disconnect() {
		window.removeEventListener('scroll', this.animateHeadOnScroll, false);
	}

}
