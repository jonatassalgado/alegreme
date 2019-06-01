import {
  Controller
} from "stimulus";
import {
  MDCChipSet
} from "@material/chips";


export default class ChipController extends Controller {
  static targets = ["chipContainer", "chip"];

  initialize() {
    const self = this;
    self.MDCChipSet = new MDCChipSet(this.chipContainerTarget);
  }
  
  select() {
    const self = this;
    const type = self.data.get('type');

    switch (type) {
      case 'filter':
        self.filterController.filter();
        break;
      case 'classifier':
        self.classifierController.classify();
        break;
    }
  }


  get filterController() {
    const parentFilter = this.context.element.closest('[data-controller="filter"]');
    return this.application.getControllerForElementAndIdentifier(parentFilter, 'filter');
  }

  get classifierController() {
    const parentClassifier = this.context.element.closest('[data-controller="classifier"]');
    return this.application.getControllerForElementAndIdentifier(parentClassifier, 'classifier');
  }
}