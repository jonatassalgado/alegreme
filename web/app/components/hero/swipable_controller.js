import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [""];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {
        await import("./swipable-component.scss")
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

}
