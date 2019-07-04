import {Controller} from "stimulus";
import {stringify}  from "query-string";
import Flipping     from 'flipping';


export default class FilterController extends Controller {
	static targets = ["filterContainer", "personas", "categories", "ocurrences", "kinds"];

	initialize() {
		const self              = this;
		const sectionIdentifier = self.data.get('sectionIdentifier');

		self.flipping     = new Flipping();
		self.subscription = postal.subscribe({
			channel : `${sectionIdentifier}`,
			topic   : `${sectionIdentifier}.updated`,
			callback: function (data, envelope) {

				self.flipping.flip();

				document.querySelectorAll('.me-card--feed').forEach(function (el) {
					if (self.flipping.states[el.dataset.flipKey] && self.flipping.states[el.dataset.flipKey]['type'] == 'MOVE' && self.flipping.states[el.dataset.flipKey]['delta']) {
						el.style.transition = '';
						el.style.transform  = `translateY(${self.flipping.states[el.dataset.flipKey]['delta']['top']}px) translateX(${self.flipping.states[el.dataset.flipKey]['delta']['left']}px)`;
					}
					if (self.flipping.states[el.dataset.flipKey] && self.flipping.states[el.dataset.flipKey]['type'] == 'ENTER') {
						el.style.opacity   = 0;
						el.style.transform = `scale(0.8)`;
					}
				});

				requestAnimationFrame(function () {

					document.querySelectorAll('.me-card--feed').forEach(function (el) {
						if (self.flipping.states[el.dataset.flipKey] && self.flipping.states[el.dataset.flipKey]['type'] == 'MOVE' && self.flipping.states[el.dataset.flipKey]['delta']) {
							el.style.transition = 'all 0.6s cubic-bezier(.54,.01,.45,.99)';
							el.style.transform  = '';
							el.style.opacity    = 1;
						}
						if (self.flipping.states[el.dataset.flipKey] && self.flipping.states[el.dataset.flipKey]['type'] == 'ENTER') {
							el.style.transition = 'all 0.4s cubic-bezier(0,.16,.45,.99) 0.350s';
							el.style.transform  = '';
							el.style.opacity    = 1;
						}
					});
				});

			}
		});

		document.addEventListener("turbolinks:before-cache", () => {
			self.subscription.unsubscribe();
		});

	}


	filter() {
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
						       personas  : resultsArray[0],
						       categories: resultsArray[1],
						       ocurrences: resultsArray[2],
						       kinds     : resultsArray[3],
						       identifier: self.data.get('sectionIdentifier'),
						       title     : self.data.get('title'),
						       defaults  : self.defaultValue
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

}
