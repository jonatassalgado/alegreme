import ApplicationController from "./application_controller"
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = ['hidden', 'visible', 'title'];
    static classes = ['title', 'body']
    static values  = {
        open:       Boolean,
        mobileOnly: Boolean
    }

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

    }

    teardown() {

    }

    toggle() {
        if (this.mobileOnlyValue) {
            if (!MobileDetector.mobile()) return
        }

        if (this.openValue) {
            this.titleTarget.classList.remove(this.titleClass)
            this.element.classList.remove(this.bodyClass)
            this.hiddenTargets.forEach((el) => {
                el.classList.add('hidden')
            })
            this.visibleTargets.forEach((el) => {
                el.classList.remove('hidden')
            })
        } else {
            this.titleTarget.classList.add(this.titleClass)
            this.element.classList.add(this.bodyClass)
            this.hiddenTargets.forEach((el) => {
                el.classList.remove('hidden')
            })
            this.visibleTargets.forEach((el) => {
                el.classList.add('hidden')
            })
        }

        this.openValue = !this.openValue
    }

}
