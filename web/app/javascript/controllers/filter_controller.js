import {Controller}        from "stimulus";
import {stringify}         from "query-string";
import Flipping            from 'flipping';
import {ProgressBarModule} from "../modules/progressbar-module";
import * as MobileDetect   from "mobile-detect";


export default class FilterController extends Controller {
	static targets = ["filterContainer", "personas", "categories", "ocurrences", "kinds"];


	initialize() {
		this.flipping = new Flipping({
			attribute: `data-collection-${this.sectionIdentifier}-flip-key`
		});
		this.pubsub   = {};
		this.md       = new MobileDetect(window.navigator.userAgent);

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.sectionIdentifier}.updated`, (data) => {
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

						if (counter < (states.length - 8)) {
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
		});

		this.pubsub.sectionCreate = PubSubModule.on(`${this.sectionIdentifier}.create`, (data) => {
			this.filter(data);
		});

		this.destroy = () => {
			this.pubsub.sectionUpdated();
			this.pubsub.sectionCreate();
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
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
						return chipElement.dataset.chipValue.toLowerCase();
					}
				});
			}

			if (this.hasKindsTarget) {
				promises[3] = this.kindsController.MDCChipSet.selectedChipIds.map((chipId) => {
					const chipElement = this.kindsController.chipsetTarget.querySelector(`#${chipId}`);
					return chipElement.innerText.toLowerCase();
				});
			}

			if (promises.length) {
				Promise.all(promises)
				       .then((resultsArray) => {
					       const urlWithFilters = stringify(
						       {
							       personas            : resultsArray[0],
							       categories          : resultsArray[1],
							       ocurrences          : resultsArray[2],
							       kinds               : resultsArray[3],
							       identifier          : this.sectionIdentifier,
							       title               : this.title,
							       defaults            : this.defaultValue,
							       init_filters_applyed: this.initFiltersApplyed,
							       origin              : this.origin,
							       similar             : opts.similar,
							       insert_after        : opts.insert_after,
							       limit               : opts.limit
						       },
						       {
							       arrayFormat: 'bracket'
						       });

					       fetch(`/collections?${urlWithFilters}`, {
						       method     : 'get',
						       headers    : {
							       'X-Requested-With': 'XMLHttpRequest',
							       'Content-type'    : 'text/javascript; charset=UTF-8',
							       'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
						       },
						       credentials: 'same-origin'
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


	get personasController() {
		return this.application.getControllerForElementAndIdentifier(this.personasTarget, 'chip');
	}


	get categoriesController() {
		return this.application.getControllerForElementAndIdentifier(this.categoriesTarget, 'chip');
	}

	get kindsController() {
		return this.application.getControllerForElementAndIdentifier(this.kindsTarget, 'chip');
	}


	get ocurrencesController() {
		return this.application.getControllerForElementAndIdentifier(this.ocurrencesTarget, 'chip');
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

	get initFiltersApplyed() {
		return this.data.get('initFiltersApplyed');
	}

	get origin() {
		return this.data.get('origin');
	}

	get sectionIdentifier() {
		return this.data.get('sectionIdentifier');
	}

	get title() {
		return this.data.get('title')
	}

}
