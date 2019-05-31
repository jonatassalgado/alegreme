import { Controller } from "stimulus";
import { MDCMenu } from "@material/menu";

export default class ClassifierSelectController extends Controller {
  static targets = [
    "moreButton",
    "menu"
  ];

  initialize() {

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

}
