import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {

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
        this.element.innerHTML = "";
        // this.stimulate("Modal::SignInComponent#close", event.target).then(payload => {
        //
        // }).catch(payload => {
        //
        // })
    }
}
