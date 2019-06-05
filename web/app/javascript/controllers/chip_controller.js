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
      case 'kinds':
        self.kindsController.classify();
        break;
      case 'tags':
        // const tagType = self.data.get('tag-type');
        self.tagsController.classify();
        break;
    }
  }


  get filterController() {
    const parentFilter = this.context.element.closest('[data-controller="filter"]');
    return this.application.getControllerForElementAndIdentifier(parentFilter, 'filter');
  }

  get kindsController() {
    const parentClassifier = this.context.element.closest('[data-controller="kinds"]');
    return this.application.getControllerForElementAndIdentifier(parentClassifier, 'kinds');
  }

  get tagsController() {
    const parentClassifier = this.context.element.closest('[data-controller="tags"]');
    return this.application.getControllerForElementAndIdentifier(parentClassifier, 'tags');
  }
}