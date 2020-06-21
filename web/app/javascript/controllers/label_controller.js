import ApplicationController from './application_controller'
import {MDCMenu}             from "@material/menu";

export default class LabelController extends ApplicationController {
	static targets = ["menuButton", "menu"];

	initialize() {
		const self = this;
	}

	openMenu() {
		const self    = this;
		const mdcMenu = new MDCMenu(self.menuTarget);
		if (mdcMenu.open) {
			mdcMenu.open = false;
		} else {
			mdcMenu.open = true;
		}
	}
}
