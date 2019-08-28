import {Controller} from "stimulus";
import {LazyloadModule} from "../modules/lazyload-module";

export default class SectionController extends Controller {
	static targets = ["section", "filter", "loadMoreButton"];

	initialize() {
		const self = this;

		self.subscription = postal.subscribe({
			channel : `${self.identifier}`,
			topic   : `${self.identifier}.updated`,
			callback: function (data, envelope) {
				LazyloadModule.init();
				self.hasMoreEventsToLoad();
			}
		});

		self.sectionTarget.parentElement.style.minHeight = `${self.sectionTarget.getBoundingClientRect().height}px`;
	}

	loadMore() {
		this.filterController.filter({
			limit: parseInt(this.itemsCount) + 8
		})
	}

	closeLoadMore() {

	}

	hasMoreEventsToLoad() {
		const self = this;

		if(self.hasLoadMoreButtonTarget){
			if (parseInt(self.itemsCount) === 16 || parseInt(self.itemsCount) >= 9) {
				self.loadMoreButtonTarget.style.display = 'none';
			} else {
				self.loadMoreButtonTarget.style.display = '';
			}
		}
	}

	get filterController() {
		return this.application.getControllerForElementAndIdentifier(this.filterTarget, 'filter');
	}

	get itemsCount() {
		return this.data.get('itemsCount');
	}

	set itemsCount(count) {
		return this.data.set('itemsCount', count);
	}

	get identifier() {
		return this.sectionTarget.id;
	}

}
