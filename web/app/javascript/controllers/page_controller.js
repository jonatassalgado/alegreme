import ApplicationController from './application_controller'

export default class PageController extends ApplicationController {
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
