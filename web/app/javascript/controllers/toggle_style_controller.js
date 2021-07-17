import ApplicationController from "./application_controller"

export default class ToggleStyleController extends ApplicationController {
    static targets = ["toggle"];
    static values  = {
        initSelected:    String,
        currentSelected: String,
        activeClass:     Array,
        inactiveClass:   Array
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
        this._toggleChip(event.currentTarget);
        this._updateStyle();
    }

    _toggleChip(currentTarget) {
        this.currentSelectedValue = currentTarget.dataset.toggleStyleIdentifier;
    }

    _updateStyle() {
        this.toggleTargets.forEach(toggle => {
            this.inactiveClassValue.forEach(cl => toggle.classList.toggle(cl, toggle.dataset.toggleStyleIdentifier !== this.currentSelectedValue))
            this.activeClassValue.forEach(cl => toggle.classList.toggle(cl, toggle.dataset.toggleStyleIdentifier === this.currentSelectedValue))
        })
    }

}
