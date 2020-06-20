import {Controller}          from "stimulus";
import {MDCRipple}           from "@material/ripple";
import {AnimateModule}       from "../modules/animate-module";

export default class MovieController extends Controller {
	static targets = ['movie', 'coverRipple'];

	initialize() {
    this.coverRiple = new MDCRipple(this.coverRippleTarget);
	}

	disconnect() {
    if (this.hasCoverRipple) {
      this.coverRiple.destroy();
    }
	}

  handleEventClick() {
		AnimateModule.animatePageHide();
	}
}