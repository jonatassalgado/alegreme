import {Controller}     from "stimulus";
import {LazyloadModule} from "../modules/lazyload-module";

export default class SectionController extends Controller {
	static targets = ["section", "filter", "scrollContainer", "loadMoreButton"];

	initialize() {
		const self      = this;
		this.scrollLeft = this.data.get('turbolinksPersistScroll');

		self.subscription = postal.subscribe({
			channel : `${self.identifier}`,
			topic   : `${self.identifier}.updated`,
			callback: function (data, envelope) {
				LazyloadModule.init();
				self.hasMoreEventsToLoad();
			}
		});

		self.sectionTarget.parentElement.style.minHeight = `${self.sectionTarget.getBoundingClientRect().height}px`;

		this.destroy = () => {
			this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	loadMore() {
		this.filterController.filter({
			limit: parseInt(this.actualEventsInCollection) + 8
		})
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
		if (value > 0) {
			this.scrollContainerTarget.scrollLeft = value;
		}
	}

}
