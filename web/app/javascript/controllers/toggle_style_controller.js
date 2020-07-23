import ApplicationController from "./application_controller"

export default class ToggleStyleController extends ApplicationController {
    static targets = ["toggle"];

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
        this.currentSelected = this.initSelected;
        this._updateStyle();
    }

    toggle(event) {
        this._toggleChip(event.currentTarget);
        this._updateStyle();
    }

    _toggleChip(currentTarget) {
        this.currentSelected = currentTarget.dataset.toggleStyleIdentifier;
    }

    _updateStyle() {
        this.toggleTargets.forEach(toggle => {
            this.inactiveClass.forEach(cl => toggle.classList.toggle(cl, toggle.dataset.toggleStyleIdentifier !== this.currentSelected))
            this.activeClass.forEach(cl => toggle.classList.toggle(cl, toggle.dataset.toggleStyleIdentifier === this.currentSelected))
        })
    }

    get initSelected() {
        return this.data.get("initSelected");
    }

    get currentSelected() {
        return this.data.get("currentSelected")
    }

    set currentSelected(value) {
        this.data.set("currentSelected", value)
    }

    get activeClass() {
        return JSON.parse(this.data.get("activeClass"));
    }

    get inactiveClass() {
        return JSON.parse(this.data.get("inactiveClass"));
    }

}
