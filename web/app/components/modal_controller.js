import ApplicationController from "../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this.beginEvent = new Event("sign-in#open")
        this.endEvent   = new Event("sign-in#close");

        document.dispatchEvent(this.beginEvent)
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    close(event) {
        this.element.innerHTML = ""
        document.dispatchEvent(this.endEvent)
    }
}
