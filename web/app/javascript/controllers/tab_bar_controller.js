import {Controller}        from 'stimulus';
import {MDCTabBar}         from '@material/tab-bar';
import {ProgressBarModule} from '../modules/progressbar-module';

export default class TabBarController extends Controller {
	static targets = ['tabBar'];

	initialize() {
		this.tabBarMDC = new MDCTabBar(this.tabBarTarget);

		this.destroy = () => {
			this.tabBarMDC.destroy();
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	open(event) {
		ProgressBarModule.show();
		setTimeout(() => {
			location.assign(event.target.parentElement.dataset.tabPath);
		}, 300)
	}

}
