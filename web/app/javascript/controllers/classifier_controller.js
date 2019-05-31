import { Controller } from "stimulus";
import { MDCMenu } from "@material/menu";
import { MDCDialog } from "@material/dialog";
import { stringify } from "query-string";


export default class ClassifierController extends Controller {
  static targets = ["menuButton", "menu", "dialog", "kinds"];

  initialize() {
    const self = this;
    self.dialog = new MDCDialog(self.dialogTarget);
  }

  openMenu() {
    const self = this;
    const mdcMenu = new MDCMenu(self.menuTarget);
    if (mdcMenu.open) {
      mdcMenu.open = false;
    } else {
      mdcMenu.open = true;
    }
  }

  openDialog() {
    const self = this;
    self.dialog.open();
  }

  classify() {
    const self = this;
    // let promises = [];

    // if (self.hasKindsTarget) {
      const selectedKindsValues = new Promise((resolve, reject) => {
        resolve(self.kindsController.MDCChipSet.selectedChipIds.map(function(chipId) {
          const chipElement = self.kindsController.chipContainerTarget.querySelector( `#${chipId}` );
          return {name: chipElement.innerText.toLowerCase(), score: 0.9};
        }))
      });
    // }

    // if (promises.length) {
    selectedKindsValues
      .then(function(result) {
        self.kindsSelected = JSON.stringify(result);
        console.log(result);
      })
      .catch(function(err) {
        console.log(err);
      });
    // }
  }

  saveKindsSelected() {
    const self = this;
    const urlWithFilters = stringify({kinds: self.kindsSelected, feature: 'kinds', event_id: self.data.get('identifier')}, {arrayFormat: 'bracket'});

    Rails.ajax({
      type: "GET",
      url: `/retrain?${urlWithFilters}`,
      success: function(response){
        console.log(response);
      },
      error: function(response){
        console.log(response)
      }
    })
  }

  get kindsController() {
    return this.application.getControllerForElementAndIdentifier(
      this.kindsTarget,
      "chip"
    );
  }
}
