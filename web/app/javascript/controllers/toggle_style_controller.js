import ApplicationController from "./application_controller"

export default class ToggleStyleController extends ApplicationController {
    static targets = ["toggle", "activeButton", "disableButton"];
    static values  = {
        status:      Boolean,
        toggleClass: Array,
    }

    initialize() {
        if (this.statusValue == null) this.statusValue = false
    }

    connect() {
        super.connect();
    }

    beforeCache() {
        super.beforeCache();
        // this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    teardown() {
        this.currentSelectedValue = this.initSelectedValue;
        this._updateStyle();
    }

    toggle(event) {
        this._updateStyle();
    }

    _updateStyle() {
        this.toggleTargets.forEach(toggle => {
            this.toggleClassValue.forEach(cl => toggle.classList.toggle(cl))
        })
        if (this.statusValue) {
            this.activeButtonTarget.classList.remove('hidden')
            this.disableButtonTarget.classList.add('hidden')
        } else {
            this.activeButtonTarget.classList.add('hidden')
            this.disableButtonTarget.classList.remove('hidden')
        }
        this.statusValue = !this.statusValue;
    }

}
