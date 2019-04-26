import { Controller } from "stimulus";
import { MDCChipSet, MDCChipSetFoundation } from "@material/chips";
import { stringify } from "query-string";

export default class ChipController extends Controller {
  static targets = ["chipContainer", "chip"];

  initialize() {
    console.log(this)
    this.MDCChipSet = new MDCChipSet(this.chipContainerTarget);
  }

  select() {
    const self = this;

    this.filterController.filter()

    // console.log(self.chipContainer);
    // console.log(self);


    // let selectedPersonaValues = self.chipContainer.selectedChipIds.map(function(chipId) {
    //     const chipElement = self.chipContainerTarget.querySelector(`#${chipId}`);
    //     return chipElement.innerText.toLowerCase();
    // });

    // let selectedCategoryValues = self.chipContainer.selectedChipIds.map(function(chipId) {
    //     const chipElement = self.chipContainerTarget.querySelector(`#${chipId}`);
    //     return chipElement.innerText.toLowerCase();
    // });

    // Promise.all([selectedPersonaValues, selectedCategoryValues])
    //   .then(function(resultsArray) {
    //     const urlWithFilters = stringify({personas: resultsArray[0], categories: resultsArray[1]}, {arrayFormat: 'bracket'});
    //     console.log(`${location.origin}?${urlWithFilters}`);
    //     // location.assign(`${location.origin}?${urlWithFilters}`);
    //   })
    //   .catch(function(err) {
    //     console.log(err)
    //   });

 
  }


  get filterController() {
    return this.application.controllers.find((ctrl) => { return ctrl.context.identifier === 'filter' })
  }
}
