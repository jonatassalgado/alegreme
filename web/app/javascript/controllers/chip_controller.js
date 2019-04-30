import { Controller } from "stimulus";
import { MDCChipSet, MDCChipSetFoundation } from "@material/chips";
import { stringify } from "query-string";

export default class ChipController extends Controller {
  static targets = ["chipContainer", "chip"];

  initialize() {
    this.MDCChipSet = new MDCChipSet(this.chipContainerTarget);
  }

  select() {
    const self = this;

    this.filterController.filter()
  }


  get filterController() {
    return this.application.controllers.find((ctrl) => { return ctrl.context.identifier === 'filter' })
  }
}
