import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this._setMinHeigth();
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    update(event) {
        this.stimulate('Hero::SwipableComponent#update')
    }

    beforeHideSwipable() {
        this._hideSwipable()
    }

    _setMinHeigth() {
        setTimeout(() => {
            if (this.element.offsetHeight > 0) {
                this.element.style.minHeight = `${this.element.offsetHeight}px`
            }
        }, 250)
    }

    _hideSwipable() {
        this.element.style.display = "none"
    }

}
