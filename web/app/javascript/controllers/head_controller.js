import {Controller} from 'stimulus';
import {MDCRipple}  from '@material/ripple';

export default class HeadController extends Controller {
	static targets = ['head', 'backButton', 'backButtonRipple'];

	initialize() {
		if (this.hasHeadTarget) {
			this.lastScrollTop    = 0;
			this.backButtonRipple = new MDCRipple(this.backButtonRippleTarget);

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
		this.backButtonRipple.destroy();
		window.removeEventListener('scroll', this.animateHeadOnScroll, false);
	}

}
