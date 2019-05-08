import { Controller } from "stimulus";
import { MDCChipSet, MDCChipSetFoundation } from "@material/chips";
import { stringify } from "query-string";

export default class FilterController extends Controller {
  static targets = ["filterContainer", "personas", "categories", "ocurrences"];

  initialize() {
  
  }


  filter() {
    const self = this;
    let promises = [];

    if (this.hasPersonasTarget) {
      let selectedPersonaValues = self.personasController.MDCChipSet.selectedChipIds.map(function(chipId) {
          const chipElement = self.personasController.chipContainerTarget.querySelector(`#${chipId}`);
          return chipElement.innerText.toLowerCase();
      });

      promises[0] = selectedPersonaValues;
    }

    if (this.hasCategoriesTarget) {
      let selectedCategoryValues = self.categoriesController.MDCChipSet.selectedChipIds.map(function(chipId) {
          const chipElement = self.categoriesController.chipContainerTarget.querySelector(`#${chipId}`);
          return chipElement.innerText.toLowerCase();
      });

      promises[1] = selectedCategoryValues;
    }

    if (this.hasOcurrencesTarget) {
      let selectedOcurrencesValues = self.ocurrencesController.MDCChipSet.selectedChipIds.map(function(chipId) {
          const chipElement = self.ocurrencesController.chipContainerTarget.querySelector(`#${chipId}`);
          return chipElement.innerText.toLowerCase();
      });

      promises[2] = selectedOcurrencesValues;
    }

    if (promises.length) {
      Promise.all(promises)
        .then(function(resultsArray) {
          const urlWithFilters = stringify({personas: resultsArray[0], categories: resultsArray[1], ocurrences: resultsArray[2]}, {arrayFormat: 'bracket'});
          // Turbolinks.clearCache();
          if (urlWithFilters !== "" && typeof urlWithFilters !== "undefined") {
            location.assing(`${location.origin}?${urlWithFilters}`);
          } else {
            location.assign(`${location.origin}`);
          }
        })
        .catch(function(err) {
          console.log(err)
        });
    }

  }


  get personasController() {
    return this.application.getControllerForElementAndIdentifier(this.personasTarget, 'chip')
  }


  get categoriesController() {
    return this.application.getControllerForElementAndIdentifier(this.categoriesTarget, 'chip')
  }


  get ocurrencesController() {
    return this.application.getControllerForElementAndIdentifier(this.ocurrencesTarget, 'chip')
  }

}
