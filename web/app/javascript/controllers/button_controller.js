import ApplicationController from "./application_controller"
import {MDCRipple}           from "@material/ripple";

export default class BottonController extends ApplicationController {
    static targets = ["button"];

    connect() {
        super.connect();
        this.setup();
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
        if (this.hasButtonTarget) {
            this.buttonRipple = new MDCRipple(this.buttonTarget);
        }
    }

    teardown() {
        if (this.hasButtonTarget) {
            this.buttonRipple.destroy();
        }
    }
}
