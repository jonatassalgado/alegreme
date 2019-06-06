import { Controller } from "stimulus";
import { MDCDialog } from "@material/dialog";
import { MDCTextField } from "@material/textfield";
import { stringify } from "query-string";


export default class KindsController extends Controller {
  static targets = ["dialog", "chipsKinds"];

  initialize() {
    const self = this;
  }
  
  openDialog() {
    const self = this;
    self.dialog = new MDCDialog(self.dialogTarget);
    self.chipsetInput = new MDCTextField(self.chipController.inputContainerTarget);
    self.dialog.open();
  }
  
  saveKindsSelected() {
    const self = this;
    
    if (self.hasChipsKindsTarget) {
      const selectedKindsValues = new Promise((resolve, reject) => {
        const result = self.chipController.MDCChipSet.selectedChipIds.map(function(chipId) {
          const chipElement = self.chipController.chipsetTarget.querySelector( `#${chipId}` );
          return {name: chipElement.innerText.toLowerCase(), score: 1};
        })
  
        resolve(result);
      });
  
      selectedKindsValues
        .then(function(result) {
          const urlWithFilters = stringify({kinds: JSON.stringify(result), feature: 'kinds', event_id: self.data.get('identifier')}, {arrayFormat: 'bracket'});
      
          fetch(`/retrain?${urlWithFilters}`, {
              method: 'get',
              headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Content-type': 'text/javascript; charset=UTF-8',
                'X-CSRF-Token': Rails.csrfToken()
              },
              credentials: 'same-origin'
            })
            .then(
              function(response) {
                response.text().then(function(data) {
                  eval(data);
                });
              }
            )
            .catch(function(err) {
              console.log('Fetch Error :-S', err);
            });
        })
        .catch(function(err) {
          console.log(err);
        });
    }

  }
 
  get chipController() {
    const self = this;
    return self.application.getControllerForElementAndIdentifier(
      self.chipsKindsTarget,
      "chip"
    );
  }
}
