import {Controller} from "stimulus";
import {stringify}  from "query-string";
import Flipping     from 'flipping';


export default class FilterController extends Controller {
	static targets = ["filterContainer", "personas", "categories", "ocurrences", "kinds"];

	initialize() {
		const self         = this;
		self.flipping      = new Flipping({
			attribute: `data-collection-${self.sectionIdentifier}-flip-key`
		});
		self.subscriptions = {};

		self.subscriptions.sectionUpdated = postal.subscribe({
			channel : `${self.sectionIdentifier}`,
			topic   : `${self.sectionIdentifier}.updated`,
			callback: function (data, envelope) {

				const flipPromise = new Promise((resolve, reject) => {
					self.flipping.flip();

					let delay     = 0.035;
					const flipped = Object.keys(self.flipping.states).forEach(function (key) {
						const state = self.flipping.states[key];
						if (state.element === undefined) {
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

						requestAnimationFrame(function () {

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

				});
			}
		});

		self.subscriptions.filterCreate = postal.subscribe(
			{
				channel : `${self.sectionIdentifier}`,
				topic   : `${self.sectionIdentifier}.create`,
				callback: function (data, envelope) {
					self.filter(data);
				}
			});

		document.addEventListener("turbolinks:before-cache", () => {
			self.subscriptions.sectionUpdated.unsubscribe();
			self.subscriptions.filterCreate.unsubscribe();
		});

	}


	filter(opts = {}) {
		const self   = this;
		let promises = [];

		self.flipping.read();

		if (this.hasPersonasTarget) {
			let selectedPersonaValues = self.personasController.MDCChipSet.selectedChipIds.map(function (chipId) {
				const chipElement = self.personasController.chipsetTarget.querySelector(`#${chipId}`);
				if (chipElement) {
					return chipElement.innerText.toLowerCase();
				}
			});

			promises[0] = selectedPersonaValues;
		}

		if (this.hasCategoriesTarget) {
			let selectedCategoryValues = self.categoriesController.MDCChipSet.selectedChipIds.map(function (chipId) {
				const chipElement = self.categoriesController.chipsetTarget.querySelector(`#${chipId}`);
				if (chipElement) {
					return chipElement.innerText.toLowerCase();
				}
			});

			promises[1] = selectedCategoryValues;
		}

		if (this.hasOcurrencesTarget) {
			let selectedOcurrencesValues = self.ocurrencesController.MDCChipSet.selectedChipIds.map(function (chipId) {
				const chipElement = self.ocurrencesController.chipsetTarget.querySelector(`#${chipId}`);
				if (chipElement) {
					return chipElement.dataset.chipValue.toLowerCase();
				}
			});

			promises[2] = selectedOcurrencesValues;
		}

		if (this.hasKindsTarget) {
			let selectedKindsValues = self.kindsController.MDCChipSet.selectedChipIds.map(function (chipId) {
				const chipElement = self.kindsController.chipsetTarget.querySelector(`#${chipId}`);
				return chipElement.innerText.toLowerCase();
			});

			promises[3] = selectedKindsValues;
		}

		if (promises.length) {
			Promise.all(promises)
			       .then(function (resultsArray) {
				       const urlWithFilters = stringify(
					       {
						       personas            : resultsArray[0],
						       categories          : resultsArray[1],
						       ocurrences          : resultsArray[2],
						       kinds               : resultsArray[3],
						       identifier          : self.sectionIdentifier,
						       title               : self.title,
						       defaults            : self.defaultValue,
						       init_filters_applyed: self.initFiltersApplyed,
						       similar             : opts.similar,
						       insert_after        : opts.insert_after,
						       limit               : opts.limit
					       },
					       {
						       arrayFormat: 'bracket'
					       });

				       fetch(`${location.pathname}?${urlWithFilters}`, {
					       method     : 'get',
					       headers    : {
						       'X-Requested-With': 'XMLHttpRequest',
						       'Content-type'    : 'text/javascript; charset=UTF-8',
						       'X-CSRF-Token'    : Rails.csrfToken()
					       },
					       credentials: 'same-origin'
				       })
					       .then(
						       function (response) {
							       response.text().then(function (data) {
								       eval(data);
							       });
						       }
					       )
					       .catch(function (err) {
						       console.log('Fetch Error :-S', err);
					       });

				       // }
			       })
			       .catch(function (err) {
				       console.log(err);
			       });
		}

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
		const self = this;

		const defaults = {
			categories: self.hasCategoriesTarget ? JSON.parse(self.categoriesController.data.get('defaultValue')) : [],
			personas  : self.hasPersonasTarget ? JSON.parse(self.personasController.data.get('defaultValue')) : [],
			ocurrences: self.hasOcurrencesTarget ? JSON.parse(self.ocurrencesController.data.get('defaultValue')) : [],
			kinds     : self.hasKindsTarget ? JSON.parse(self.kindsController.data.get('defaultValue')) : []
		};

		return JSON.stringify(defaults)
	}

	get initFiltersApplyed() {
		const self = this;

		return self.data.get('initFiltersApplyed');
	}

	get sectionIdentifier() {
		return this.data.get('sectionIdentifier');
	}

	get title() {
		return this.data.get('title')
	}

}
