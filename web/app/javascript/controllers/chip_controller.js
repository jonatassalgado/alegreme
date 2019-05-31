import {
  Controller
} from "stimulus";
import {
  MDCChipSet
} from "@material/chips";


export default class ChipController extends Controller {
  static targets = ["chipContainer", "chip"];

  initialize() {
    this.MDCChipSet = new MDCChipSet(this.chipContainerTarget);
  }

  select() {
    const self = this;
    const type = self.data.get('type');

    switch (type) {
      case 'filter':
        this.filterController.filter();
        break;
      case 'classifier':
        this.classifierController.classify();
        break;
    }
  }


  get filterController() {
    return this.application.controllers.find((ctrl) => {
      return ctrl.context.identifier === 'filter';
    })
  }

  get classifierController() {
    return this.application.controllers.find((ctrl) => {
      return ctrl.context.identifier === 'classifier';
    })
  }
}