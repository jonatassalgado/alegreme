import { Controller } from "stimulus";
import { html, render } from "lit-html";
import { MDCChipSet, MDCChipSetFoundation } from "@material/chips";
import { stringify } from "query-string";

export default class ChipController extends Controller {
  static targets = ["chipContainer", "chip"];

  initialize() {
    this.chipContainer = new MDCChipSet(this.chipContainerTarget);
    this.chipFoundation = new MDCChipSetFoundation();
  }

  select(event) {
    const self = this;

    console.log(self.chipContainer);
    console.log(self);


    let selectedChipsValues = self.chipContainer.selectedChipIds.map(function(chipId) {
        const chipElement = self.chipContainerTarget.querySelector(`#${chipId}`);
        return chipElement.innerText.toLowerCase();
    });

    Promise.all(selectedChipsValues)
      .then(function(resultsArray) {
        const urlWithFilters = stringify({personas: resultsArray}, {arrayFormat: 'bracket'});
        console.log(`${location.origin}?${urlWithFilters}`);
        location.assign(`${location.origin}?${urlWithFilters}`);
      })
      .catch(function(err) {
        console.log(err)
      });

 
  }
}
