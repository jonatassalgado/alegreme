import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [""];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {

    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    beforeLike() {
        this.element.classList.add('hidden');
    }

    beforeDislike() {
        this.element.classList.add('hidden');
    }

}
