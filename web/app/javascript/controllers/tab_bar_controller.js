import {Controller}        from 'stimulus';
import {MDCTabBar}         from '@material/tab-bar';
import {ProgressBarModule} from '../modules/progressbar-module';

export default class TabBarController extends Controller {
	static targets = ['tabBar'];

	initialize() {
		this.tabBarMDC = new MDCTabBar(this.tabBarTarget);

		if (this.hasTabBarTarget) {
			this.lastScrollTop = 0;

			this.animateTabBarOnScroll = () => {
				var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;

				if (window.scrollY > 0) {
					if (currentScrollTop > this.lastScrollTop){
						requestAnimationFrame(() => {
							this.tabBarTarget.classList.add('me-tab-bar--with-shadow')
						});
					}
				} else {
					requestAnimationFrame(() => {
						this.tabBarTarget.classList.remove('me-tab-bar--with-shadow')
					});
				}
				this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
			}

			window.addEventListener('scroll', this.animateTabBarOnScroll, {capture: false, passive: true});
		}

		this.destroy = () => {
			window.removeEventListener('scroll', this.animateTabBarOnScroll, false);
		};
	}

	disconnect() {
		// document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	open(event) {
		// this.tabBarMDC.scrollIntoView(event.target.offsetParent.dataset.tabIdentifier);
		// this.tabBarMDC.activateTab(event.target.offsetParent.dataset.tabIdentifier);

		PubSubModule.emit("tabBar.update", {})

		setTimeout(() => {
			Turbolinks.visit(event.target.parentElement.dataset.tabPath);
		}, 250)
	}

}
