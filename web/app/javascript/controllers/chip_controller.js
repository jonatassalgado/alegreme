import {Controller}   from "stimulus";
import {MDCChipSet}   from "@material/chips";
import {html, render} from "lit-html";

export default class ChipController extends Controller {
	static targets = ["chipset", "container", "chip", "input", "inputContainer"];

	initialize() {
		this.MDCChipSet = new MDCChipSet(this.chipsetTarget);
		this.pubsub     = {};

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.sectionIdentifier}.updated`, (data) => {
			requestIdleCallback(() => {
				if(this.hasChipsetTarget) {
					this.MDCChipSet = new MDCChipSet(this.chipsetTarget);
				}
			}, {timeout: 250})
		});

		if (this.hasInputTarget) {
			this.inputTarget.addEventListener('keydown', event => {
				if (event.key === 'Enter' || event.keyCode === 13) {
					this.create();
				}
			});
		}

		this.destroy = () => {
			this.MDCChipSet.destroy();
			this.pubsub.sectionUpdated();
			if (this.hasInputTarget) {
				this.inputTarget.removeEventListener('keydown');
			}
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	select() {
		const type = this.data.get("type");

		switch (type) {
			case "filter":
				// flipping.read();
				setTimeout(() => {
					this.sectionController.filter();
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
		if (this.hasChipsetTarget) {
			const chipEl = document.createElement("div");
			chipEl.classList.add("me-chip", "mdc-chip", "mdc-chip--selected");
			chipEl.dataset.target = "chip.chip";
			chipEl.dataset.action = "click->chip#select";

			this.chipsetTarget.appendChild(chipEl);
			this.MDCChipSet.addChip(chipEl);
			this.setSelected(chipEl);
		}
	}

	setSelected(chipEl) {
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
			const currentMDCChip = this.MDCChipSet.chips.filter(chip => chip.id == chipEl.id);

			resolve(currentMDCChip[0]);
		});

		currentMDCChipPromise
			.then((currentMDCChip) => {
				currentMDCChip.selected = true;
				render(chipTemplate(this.inputTarget.value.toLowerCase()), chipEl)
				this.inputTarget.value = '';
			})
			.catch((err) => {
				console.log(err);
			});
	}


	get sectionController() {
		const parentClassifier = this.context.element.closest(
			'[data-controller="section"]'
		);
		return this.application.getControllerForElementAndIdentifier(
			parentClassifier,
			"section"
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

	get sectionIdentifier() {
		const section = this.chipsetTarget.closest('[data-controller="section"]');
		if (this.hasChipsetTarget && section) {
			return section.id;
		}
	}

}
