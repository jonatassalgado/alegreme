import ApplicationController from "./application_controller"
import {MDCRipple}           from "@material/ripple";
import {AnimateModule}       from "../modules/animate-module";

export default class MovieController extends ApplicationController {
    static targets = ["movie", "coverRipple"];

    connect() {
        super.connect();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
        this.coverRiple = new MDCRipple(this.coverRippleTarget);
    }

    teardown() {
        if (this.hasCoverRipple) {
            this.coverRiple.destroy();
        }
    }

    handleEventClick() {
        AnimateModule.animatePageHide();
    }
}
