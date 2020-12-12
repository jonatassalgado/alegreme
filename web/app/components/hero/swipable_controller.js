import ApplicationController from "../../javascript/controllers/application_controller"
import {debounce}            from "../../javascript/utilities";

export default class extends ApplicationController {
    static targets = [""];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this.element.style.minHeight = `${this.element.offsetHeight}px`
        document.addEventListener('hero--swipable:liked-or-disliked', debounce(this.update.bind(this), 750))
    }

    teardown() {
        document.removeEventListener('hero--swipable:liked-or-disliked', debounce(this.update.bind(this), 750))
    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    update(event) {
        const swipable = document.querySelector('[data-controller="hero--swipable"]')
        this.stimulate('Hero::SwipableComponent#update', swipable)
            .then(payload => {

            }).catch(payload => {

        })
    }

}
