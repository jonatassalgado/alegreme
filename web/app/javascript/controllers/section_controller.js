import {Controller}      from "stimulus";
import {LazyloadModule}  from "modules/lazyload-module";
import * as MobileDetect from "mobile-detect";

export default class SectionController extends Controller {
	static targets = ['section', 'filter', 'scrollContainer', 'loadMoreButton', 'seeAll'];

	initialize() {
		this.scrollLeft = this.data.get('turbolinksPersistScroll');
		this.md         = new MobileDetect(window.navigator.userAgent);
		this.pubsub     = {};

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.identifier}.updated`, (data) => {
			LazyloadModule.lazyloadFeed();
			this.hasMoreEventsToLoad();
			// this.scrollLeft = 0;
			this.data.set("load-more-loading", false);
		});


		if (!this.md.mobile()) {
			this.sectionTarget.parentElement.style.minHeight = `${this.sectionTarget.getBoundingClientRect().height}px`;
		}

		this.destroy = () => {
			this.pubsub.sectionUpdated();
			this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}


	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	loadMore() {
		this.data.set('loadMoreLoading', true);

		if (this.md.mobile() && this.seeAllTarget.dataset.continueToPath !== "" && this.seeAllTarget.dataset.continueToPath !== undefined) {
			location.assign(this.seeAllTarget.dataset.continueToPath);
		} else {
			this.filterController.filter({
				limit: parseInt(this.actualEventsInCollection) + 16
			})
		}
	}

	hasMoreEventsToLoad() {
		const self = this;

		if (self.hasLoadMoreButtonTarget) {
			if (parseInt(self.actualEventsInCollection) >= parseInt(self.totalEventsInCollection)) {
				self.loadMoreButtonTarget.style.display = 'none';
			}
		}
	}

	get filterController() {
		return this.application.getControllerForElementAndIdentifier(this.filterTarget, 'filter');
	}

	get actualEventsInCollection() {
		return this.data.get('actualEventsInCollection');
	}

	get totalEventsInCollection() {
		return this.data.get('totalEventsInCollection');
	}

	get identifier() {
		return this.sectionTarget.id;
	}

	set turbolinksPersistScroll(value) {
		this.data.set('turbolinksPersistScroll', value);
	}

	set scrollLeft(value) {
		if (value >= 0) {
			this.scrollContainerTarget.scrollLeft = value;
		}
	}

}
