import {Controller}   from "stimulus";
import {MDCChipSet}   from "@material/chips";
import {html, render} from "lit-html";

export default class ChipController extends Controller {
	static targets = ["chipset", "container", "chip", "input", "inputContainer"];

	initialize() {
		const self              = this;
		const sectionIdentifier = self.chipsetTarget.parentElement.dataset.filterSectionIdentifier;

		self.MDCChipSet = new MDCChipSet(self.chipsetTarget);

		postal.subscribe({
			channel : `${sectionIdentifier}`,
			topic   : `${sectionIdentifier}.updated`,
			callback: function (data, envelope) {

				setTimeout(function () {
					self.MDCChipSet = new MDCChipSet(self.chipsetTarget);
				}, 550)

			}
		});

		if (self.hasInputTarget) {
			self.inputTarget.addEventListener('keydown', function (event) {
				if (event.key === 'Enter' || event.keyCode === 13) {
					self.create();
				}
			});
		}
	}

	select() {
		const self = this;
		const type = self.data.get("type");

		switch (type) {
			case "filter":
				// flipping.read();
				setTimeout(function () {
					self.filterController.filter();
				}, 250);
				break;
			case "kinds":
				// self.kindsController.classify();
				break;
			case "tags":
				// self.tagsController.classify();
				break;
		}
	}

	create() {
		const self = this;

		if (self.hasChipTarget) {

			const chipEl = document.createElement("div");
			chipEl.classList.add("me-chip", "mdc-chip", "mdc-chip--selected");
			chipEl.dataset.target = "chip.chip";
			chipEl.dataset.action = "click->chip#select";

			self.chipsetTarget.appendChild(chipEl);
			self.MDCChipSet.addChip(chipEl);
			self.setSelected(chipEl);
		}
	}

	setSelected(chipEl) {
		const self = this;

		const chipTemplate          = (text) => html`
		      <div class="mdc-chip__checkmark">
		        <svg class="mdc-chip__checkmark-svg" viewBox="-2 -3 30 30">
		          <path class="mdc-chip__checkmark-path" fill="none" stroke="black" d="M1.73,12.91 8.1,19.28 22.79,4.59" />
		        </svg>
		      </div>
		      <div class="mdc-chip__text">
		        ${text}
		      </div>
		    `;
		const currentMDCChipPromise = new Promise((resolve, reject) => {
			const currentMDCChip = self.MDCChipSet.chips.filter(function (chip) {
				return chip.id == chipEl.id;
			})

			resolve(currentMDCChip[0]);
		});

		currentMDCChipPromise
			.then(function (currentMDCChip) {
				currentMDCChip.selected = true;
				render(chipTemplate(self.inputTarget.value.toLowerCase()), chipEl)
				self.inputTarget.value = '';
			})
			.catch(function (err) {
				console.log(err);
			});
	}

	// get sectionController() {
	// 	const parentSection = this.context.element.closest(
	// 		'[data-controller="section"]'
	// 	);
	// 	return this.application.getControllerForElementAndIdentifier(
	// 		parentSection,
	// 		"section"
	// 	);
	// }

	get filterController() {
		const parentClassifier = this.context.element.closest(
			'[data-controller="filter"]'
		);
		return this.application.getControllerForElementAndIdentifier(
			parentClassifier,
			"filter"
		);
	}

	get kindsController() {
		const parentClassifier = this.context.element.closest(
			'[data-controller="kinds"]'
		);
		return this.application.getControllerForElementAndIdentifier(
			parentClassifier,
			"kinds"
		);
	}

	get tagsController() {
		const parentClassifier = this.context.element.closest(
			'[data-controller="tags"]'
		);
		return this.application.getControllerForElementAndIdentifier(
			parentClassifier,
			"tags"
		);
	}

}
