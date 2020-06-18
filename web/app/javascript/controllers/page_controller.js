import {Controller} from 'stimulus';

export default class PageController extends Controller {
	static targets = ['page'];

	connect() {
    this.pubsub = {};

    this.pubsub.categoriesUpdate = PubSubModule.on("tabBar.update", (data) => {
			// this.pageTarget.style.opacity = 0;
		});
	}

	disconnect() {
    this.pubsub.categoriesUpdate();
	}

}
