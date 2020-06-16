import {Controller}        from "stimulus";
import {LazyloadModule}    from "modules/lazyload-module";
import {MDCRipple}         from "@material/ripple";
import * as MobileDetect   from "mobile-detect";
import Flipping            from "flipping";
import {ProgressBarModule} from "../modules/progressbar-module";
import {AnimateModule}     from "modules/animate-module"

export default class SectionController extends Controller {
	static targets = ['section', 'filter', 'scrollContainer', 'loadMoreButton', 'seeAll', 'personas', 'categories', 'ocurrences', 'kinds'];

	initialize() {
		this.scrollLeft = this.data.get('turbolinksPersistScroll');
		this.md         = new MobileDetect(window.navigator.userAgent);
		this.pubsub     = {};
		this.ripples    = [];
		this.rootMargin = this.md.mobile() ? '1000px' : '500px';
		this.flipping = new Flipping({
			attribute: `data-collection-${this.identifier}-flip-key`
		});

		this.loadMoreButtonTargets.forEach((button) => {
			this.ripples.push(new MDCRipple(button));
		});

		if (this.data.get('infiniteScroll') === 'true') {
			this.observer = new IntersectionObserver((entries, observer) => {
					entries.forEach((entry) => {

						if (this.hasLoadMoreButtonTarget) {
							if (entry.isIntersecting) {
								entry.target.disabled                                     = true;
								entry.target.innerText = 'Carregando...';
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
			if (!this.md.mobile()) {
				const flipPromise = new Promise((resolve, reject) => {
					this.flipping.flip();

					let delay   = 0.035;
					let counter = 0;
					let states  = Object.keys(this.flipping.states);

					const flipped = states.forEach((key) => {
						counter++;

						const state = this.flipping.states[key];
						if (state.element === undefined) {
							return;
						}

						if (states.length > 48 && counter < (states.length - 8)) {
							return;
						}

						if (state.type === 'MOVE' && state.delta) {
							state.element.style.transition = '';
							state.element.style.transform  = `translateY(${state.delta.top}px) translateX(${state.delta.left}px)`;
						}
						if (state.type === 'ENTER') {
							state.element.style.opacity   = 0;
							state.element.style.transform = `scale(0.8)`;
						}

						requestAnimationFrame(() => {

							if (state.type === 'MOVE' && state.delta) {
								state.element.style.transition = `transform 0.6s cubic-bezier(.54,.01,.45,.99)`;
								state.element.style.transform  = '';
								state.element.style.opacity    = 1;
							}
							if (state.type === 'ENTER') {
								state.element.style.transition = `transform 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s, opacity 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s`;
								state.element.style.transform  = '';
								state.element.style.opacity    = 1;
							}

							delay = delay + 0.035;
						});
					});

					resolve(flipped)
				});

				flipPromise.then(() => {
					ProgressBarModule.hide();
				});
			} else {
				ProgressBarModule.hide();
			}

			LazyloadModule.lazyloadFeed();
			this.hasMoreEventsToLoad();
			this.data.set("load-more-loading", false);
			// this.scrollLeft = 0;
		});


		this.pubsub.sectionCreate = PubSubModule.on(`${this.identifier}.create`, (data) => {
			this.filter(data);
		});


		this.pubsub.categoriesUpdate = PubSubModule.on("chip-set.update", (data) => {
			this.sectionTarget.style.opacity = 0;
		});


		// if (!this.md.mobile()) {
		// 	this.sectionTarget.parentElement.style.minHeight = `${this.sectionTarget.getBoundingClientRect().height}px`;
		// }

		this.destroy = () => {
			this.pubsub.sectionUpdated();
			this.pubsub.sectionCreate();
			this.pubsub.categoriesUpdate();
			this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
			this.sectionTarget.style.opacity = 1;
			this.ripples.forEach((ripple) => {
				ripple.destroy();
			});
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}


	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	seeMoreInNewPage() {
		if (this.data.has('continueToPath')) {
			AnimateModule.animatePageHide();
			setTimeout(() => {
				Turbolinks.visit(this.data.get('continueToPath'));
			}, 250)
		}
	}

	loadMoreHere() {
		this.data.set('loadMoreLoading', true);

		// if (this.actualEventsInCollection >= 36 &&
		// 	this.loadMoreButtonTarget.dataset.continueToPath !== "" &&
		// 	this.loadMoreButtonTarget.dataset.continueToPath !== undefined) {
		// 	location.assign(this.loadMoreButtonTarget.dataset.continueToPath);
		// } else {
			this.filter()
		// }
	}

	filter(opts = {}) {
		ProgressBarModule.show();

		requestIdleCallback(() => {
			let promises = [];

			this.flipping.read();

			if (this.hasPersonasTarget) {
				promises[0] = this.personasController.MDCChipSet.selectedChipIds.map((chipId) => {
					const chipElement = this.personasController.chipsetTarget.querySelector(`#${chipId}`);
					if (chipElement) {
						return chipElement.innerText.toLowerCase();
					}
				});
			}

			if (this.hasCategoriesTarget) {
				promises[1] = this.categoriesController.MDCChipSet.selectedChipIds.map((chipId) => {
					const chipElement = this.categoriesController.chipsetTarget.querySelector(`#${chipId}`);
					if (chipElement) {
						return chipElement.innerText.toLowerCase();
					}
				});
			}

			if (this.hasOcurrencesTarget) {
				promises[2] = this.ocurrencesController.MDCChipSet.selectedChipIds.map((chipId) => {
					const chipElement = this.ocurrencesController.chipsetTarget.querySelector(`#${chipId}`);
					if (chipElement) {
						return chipElement.dataset.filterValue.toLowerCase();
					}
				});
			}

			if (this.hasKindsTarget) {
				promises[3] = this.kindsController.MDCChipSet.selectedChipIds.map((chipId) => {
					const chipElement = this.kindsController.chipsetTarget.querySelector(`#${chipId}`);
					return chipElement.innerText.toLowerCase();
				});
			}

			if (promises) {
				Promise.all(promises)
				       .then((resultsArray) => {
					       const params = {
						       data : {
							       personas            : resultsArray[0],
							       categories          : resultsArray[1],
							       ocurrences          : resultsArray[2],
							       kinds               : resultsArray[3],
							       identifier          : this.identifier,
							       title               : this.title,
							       defaults            : this.defaultValue,
							       init_filters_applyed: this.initFiltersApplyed,
							       origin              : this.origin,
							       continue_to_path    : this.continueToPath,
							       similar             : opts.similar,
							       insert_after        : opts.insert_after,
							       limit               : parseInt(this.actualEventsInCollection) + 16
						       },
						       props: {
							       disposition    : this.data.get('disposition'),
							       infinite_scroll: this.data.get('infiniteScroll')
						       }
					       };

					       fetch(`/api/collections`, {
						       method     : 'POST',
						       headers    : {
							       'Content-type'    : 'application/json; charset=UTF-8',
							       'Accept'          : 'text/javascript',
							       'X-Requested-With': 'XMLHttpRequest',
							       'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
						       },
						       credentials: 'same-origin',
						       body       : JSON.stringify(params)
					       })
						       .then(
							       (response) => {
								       response.text().then((data) => {
									       eval(data);
								       });
							       }
						       )
						       .catch(err => {
							       console.log('Fetch Error :-S', err);
						       });

					       // }
				       })
				       .catch(err => {
					       console.log(err);
				       });
			}
		}, {timeout: 500});

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

	set turbolinksPersistScroll(value) {
		this.data.set('turbolinksPersistScroll', value);
	}

	set scrollLeft(value) {
		if (value >= 0) {
			this.scrollContainerTarget.scrollLeft = value;
		}
	}

	get initFiltersApplyed() {
		return this.data.get('initFiltersApplyed');
	}

	get origin() {
		return this.data.get('origin');
	}

	get continueToPath() {
		return this.data.get('continueToPath');
	}

	get identifier() {
		return this.data.get('identifier');
	}

	get title() {
		return this.data.get('title')
	}

	get personasController() {
		return this.application.getControllerForElementAndIdentifier(this.personasTarget, 'filter');
	}


	get categoriesController() {
		return this.application.getControllerForElementAndIdentifier(this.categoriesTarget, 'filter');
	}

	get kindsController() {
		return this.application.getControllerForElementAndIdentifier(this.kindsTarget, 'filter');
	}


	get ocurrencesController() {
		return this.application.getControllerForElementAndIdentifier(this.ocurrencesTarget, 'filter');
	}

	get defaultValue() {
		const defaults = {
			categories: this.hasCategoriesTarget ? JSON.parse(this.categoriesController.data.get('defaultValue')) : [],
			personas  : this.hasPersonasTarget ? JSON.parse(this.personasController.data.get('defaultValue')) : [],
			ocurrences: this.hasOcurrencesTarget ? JSON.parse(this.ocurrencesController.data.get('defaultValue')) : [],
			kinds     : this.hasKindsTarget ? JSON.parse(this.kindsController.data.get('defaultValue')) : []
		};

		return JSON.stringify(defaults)
	}

}
