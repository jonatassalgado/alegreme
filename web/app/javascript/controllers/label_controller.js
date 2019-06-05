import { Controller } from "stimulus";
import { MDCMenu } from "@material/menu";
import { MDCDialog } from "@material/dialog";
import { stringify } from "query-string";


export default class LabelController extends Controller {
  static targets = ["menuButton", "menu"];

  initialize() {
    const self = this;
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
