import { Controller } from "stimulus";
import { MDCMenu } from "@material/menu";
import { MDCDialog } from "@material/dialog";
import { stringify } from "query-string";


export default class KindsController extends Controller {
  static targets = ["dialog", "kinds"];

  initialize() {
    const self = this;
  }
  
  openDialog() {
    const self = this;
    self.dialog = new MDCDialog(self.dialogTarget);
    self.dialog.open();
  }
  
  classify() {
    const self = this;

    if (self.hasKindsTarget) {
      const selectedKindsValues = new Promise((resolve, reject) => {
        const result = self.kindsController.MDCChipSet.selectedChipIds.map(function(chipId) {
          const chipElement = self.kindsController.chipContainerTarget.querySelector( `#${chipId}` );
          return {name: chipElement.innerText.toLowerCase(), score: 0.9};
        })

        resolve(result);
      });

      selectedKindsValues
        .then(function(result) {
          self.kindsSelected = JSON.stringify(result);
          console.log(result);
        })
        .catch(function(err) {
          console.log(err);
        });
    }
  }

  saveKindsSelected() {
    const self = this;
    const urlWithFilters = stringify({kinds: self.kindsSelected, feature: 'kinds', event_id: self.data.get('identifier')}, {arrayFormat: 'bracket'});

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
          if (response.status !== 200) {
            console.log('Looks like there was a problem. Status Code: ' + response.status);
            return;
          }

          response.text().then(function(data) {
            eval(data);
          });
        }
      )
      .catch(function(err) {
        console.log('Fetch Error :-S', err);
      });
  }

  get kindsController() {
    const self = this;
    return self.application.getControllerForElementAndIdentifier(
      self.kindsTarget,
      "chip"
    );
  }
}
