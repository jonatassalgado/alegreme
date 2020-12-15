import ApplicationController from "../../javascript/controllers/application_controller"
import {debounce}            from "../../javascript/utilities";

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this._setMinHeigth();
        document.addEventListener('hero--swipable:liked-or-disliked', debounce(this.update.bind(this), 250))
    }

    teardown() {
        document.removeEventListener('hero--swipable:liked-or-disliked', debounce(this.update.bind(this), 250))
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

    afterHiddenSwipable() {
        this._removeMinHeight()
    }

    _setMinHeigth() {
        this.element.style.minHeight = `${this.element.offsetHeight}px`
    }

    _removeMinHeight() {
        this.element.style.minHeight = ""
    }

}
