import ApplicationController from './application_controller'
import {MDCChipSet}          from "@material/chips";
import {html, render}        from "lit-html";

export default class FormChipSetController extends ApplicationController {
	static targets = ["chipset", "input", "hiddenInputs"];

	initialize() {
		this.MDCChipSet           = new MDCChipSet(this.chipsetTarget);
		this.MDCChipSetFoundation = this.MDCChipSet.foundation_;

		this.populateHiddenInputs();

		if (this.hasInputTarget) {
			this.inputTarget.addEventListener('keydown', event => {
				if (event.key === 'Enter' || event.keyCode === 13) {
					this.create();
				}
			});
		}

		this.destroy = () => {
			this.MDCChipSet.destroy();
			if (this.hasInputTarget) {
				this.inputTarget.removeEventListener('keydown');
			}
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	chipSelection() {
		this.populateHiddenInputs();
	}

	create() {
		if (this.hasChipsetTarget) {
			const chipEl = document.createElement("div");
			chipEl.classList.add("me-chip", "mdc-chip", "mdc-chip--selected");
			chipEl.dataset.target = "form-chip-set.chip";
			chipEl.dataset.action = "MDCChip:selection->form-chip-set#chipSelection"

			const selectedChipInnerTemplate = (text) => html`
        <div class="mdc-chip__checkmark">
          <svg class="mdc-chip__checkmark-svg" viewBox="-2 -3 30 30">
            <path class="mdc-chip__checkmark-path" fill="none" stroke="black" d="M1.73,12.91 8.1,19.28 22.79,4.59" />
          </svg>
        </div>
        <div class="mdc-chip__text">
          ${text}
        </div>
      `;

			this.chipsetTarget.appendChild(chipEl);
			this.MDCChipSet.addChip(chipEl);
			this.MDCChipSetFoundation.select(chipEl.id);

			render(selectedChipInnerTemplate(this.inputTarget.value.toLowerCase()), chipEl)
			this.populateHiddenInputs();

			this.inputTarget.value = '';
		}
	}

	populateHiddenInputs() {
		const hiddenInputs         = []
		const hiddenInputTeamplate = (value) => html`<input multiple="multiple" value="${value.toLowerCase()}" type="hidden" name="${this.model}[${this.column}_attributes][]">`;

		if (this.MDCChipSet) {
			this.MDCChipSet.selectedChipIds.forEach((chipId, i) => {
				let chip = this.chipsetTarget.querySelector(`#${chipId}`);
				hiddenInputs.push(hiddenInputTeamplate(chip.innerText));
			});
			render(hiddenInputs, this.hiddenInputsTarget)
		}
	}

	get model() {
		return this.data.get('model');
	}

	get column() {
		return this.data.get('column');
	}

}
