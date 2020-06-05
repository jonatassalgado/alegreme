import {Controller} from 'stimulus';

export default class HeadController extends Controller {
	static targets = ['head'];

	initialize() {
		if (this.hasHeadTarget) {
			var lastScrollTop = 0;

			window.addEventListener('scroll', (e) => {
				var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
				if (window.scrollY > 250) {
					if (currentScrollTop > lastScrollTop){
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
				lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
			}, {capture: false, passive: true});
		}
	}

	disconnect() {

	}

}
