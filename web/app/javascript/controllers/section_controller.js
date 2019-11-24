import {Controller}      from "stimulus";
import {LazyloadModule}  from "modules/lazyload-module";
import {MDCRipple}       from "@material/ripple";
import * as MobileDetect from "mobile-detect";

export default class SectionController extends Controller {
	static targets = ['section', 'filter', 'scrollContainer', 'loadMoreButton', 'seeAll'];

	initialize() {
		this.scrollLeft = this.data.get('turbolinksPersistScroll');
		this.md         = new MobileDetect(window.navigator.userAgent);
		this.pubsub     = {};
		this.ripples    = [];
		this.rootMargin = this.md.mobile() ? '1000px' : '500px';

		this.loadMoreButtonTargets.forEach((button) => {
			this.ripples.push(new MDCRipple(button));
		});

		if (this.data.get('infiniteScroll') === 'true') {
			this.observer = new IntersectionObserver((entries, observer) => {
					entries.forEach((entry) => {

						if (this.hasLoadMoreButtonTarget) {
							if (entry.isIntersecting) {
								entry.target.disabled                                     = true;
								entry.target.querySelector('.me-button__label').innerText = 'Carregando...';
								this.loadMore();
							} else {

							}
						}
					})
				},
				{
					threshold : 0.1,
					rootMargin: this.rootMargin
				}
			);

			this.loadMoreButtonTargets.forEach((loadMoreButton) => {
				this.observer.observe(loadMoreButton);
			});
		}

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.identifier}.updated`, (data) => {
			LazyloadModule.lazyloadFeed();
			this.hasMoreEventsToLoad();
			this.data.set("load-more-loading", false);
			// this.scrollLeft = 0;
		});


		if (!this.md.mobile()) {
			this.sectionTarget.parentElement.style.minHeight = `${this.sectionTarget.getBoundingClientRect().height}px`;
		}

		this.destroy = () => {
			this.pubsub.sectionUpdated();
			this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
			this.ripples.forEach((ripple) => {
				ripple.destroy();
			});
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}


	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	loadMore() {
		this.data.set('loadMoreLoading', true);

		if (this.actualEventsInCollection >= 24 &&
			this.loadMoreButtonTarget.dataset.continueToPath !== "" &&
			this.loadMoreButtonTarget.dataset.continueToPath !== undefined) {
			location.assign(this.loadMoreButtonTarget.dataset.continueToPath);
		} else {
			this.filterController.filter({
				limit          : parseInt(this.actualEventsInCollection) + 16,
				disposition    : this.data.get('disposition'),
				infinite_scroll: this.data.get('infinite_scroll')
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
