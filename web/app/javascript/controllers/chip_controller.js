import { Controller } from "stimulus";
import { MDCChipSet } from "@material/chips";
import { html, render } from "lit-html";

export default class ChipController extends Controller {
  static targets = ["chipset", "container", "chip", "input", "inputContainer"];

  initialize() {
    const self = this;
    self.MDCChipSet = new MDCChipSet(this.chipsetTarget);
  }

  select() {
    const self = this;
    const type = self.data.get("type");

    switch (type) {
      case "filter":
        self.filterController.filter();
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

    const chipTemplate = (text) => html `
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
      const currentMDCChip = self.MDCChipSet.chips.filter(function(chip) {
        return chip.id == chipEl.id;
      })

      resolve(currentMDCChip[0]);
    });

    currentMDCChipPromise
      .then(function(currentMDCChip) {
        currentMDCChip.selected = true;
        render(chipTemplate(self.inputTarget.value.toLowerCase()), chipEl)
        self.inputTarget.value = '';
      })
      .catch(function(err) {
        console.log(err);
      });
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
