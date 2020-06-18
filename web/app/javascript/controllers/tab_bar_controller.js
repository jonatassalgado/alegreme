import {Controller}        from 'stimulus';
import {MDCTabBar}         from '@material/tab-bar';
import {ProgressBarModule} from '../modules/progressbar-module';

export default class TabBarController extends Controller {
	static targets = ['tabBar', 'scroller'];

	connect() {
		this.setScrollLeft         = this.data.get('turbolinksPersistScroll');
		this.MDCTabBar             = new MDCTabBar(this.tabBarTarget);
		this.setActiveTab          = this.currentAction;
		this.activeAnimateOnScroll = true;

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		this.setTurbolinksPersistScroll = this.scrollerTarget.scrollLeft;
		this.MDCTabBar.tabList_.forEach((tab) => {
			tab.deactivate();
		})
		this.MDCTabBar.destroy();
		window.removeEventListener('scroll', this.animateTabBarOnScroll, false);
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	open(event) {
		// PubSubModule.emit("tabBar.update", {})
		setTimeout(() => {
			Turbolinks.visit(event.target.parentElement.dataset.tabPath);
		}, 150)
	}

	set setActiveTab(value) {
		if (value) {
				const currentTab = this.MDCTabBar.tabList_.filter((tab) => {
					return tab.root_.attributes['data-section'].value == value;
				})[0]

				if (!this.isPreview) this.scrollerTarget.scrollLeft = currentTab.root_.offsetLeft;
				currentTab.activate()
		}
	}

	set activeAnimateOnScroll(value) {
		if (value && this.hasTabBarTarget) {
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
	}

	set setTurbolinksPersistScroll(value) {
		this.data.set('turbolinksPersistScroll', value);
	}

	set setScrollLeft(value) {
		if (value >= 0) {
			this.scrollerTarget.scrollLeft = value;
		}
	}

	get currentAction() {
		return `${document.body.dataset.controller}#${document.body.dataset.action}`
	}

	get isPreview() {
    return document.documentElement.hasAttribute('data-turbolinks-preview');
  }

}
