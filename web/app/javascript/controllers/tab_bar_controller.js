import {Controller}        from 'stimulus';
import {MDCTabBar}         from '@material/tab-bar';
import {ProgressBarModule} from '../modules/progressbar-module';

export default class TabBarController extends Controller {
	static targets = ['tabBar'];

	initialize() {
		this.tabBarMDC                        = new MDCTabBar(this.tabBarTarget);
		// this.tabBarMDC.useAutomaticActivation = false;
		// this.tabBarMDC.focusOnActivate        = false;

		this.destroy = () => {
			// this.tabBarMDC.destroy();
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
