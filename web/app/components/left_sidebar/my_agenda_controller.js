import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this.element.addEventListener("cable-ready:after-morph", event => {
            this.element.querySelector("#calendar").removeAttribute('data-reflex-permanent')
        })
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    beforeInDay(anchorElement) {
        document.querySelector(`#main-sidebar--group-${anchorElement.dataset.day}`).scrollIntoView({ block: 'start',  behavior: 'smooth' })
    }

}
