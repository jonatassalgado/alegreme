import ApplicationController from "../javascript/controllers/application_controller"

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

    endEdit(e) {
        e.target.parentElement.classList.add("hidden");
        this.stimulate("UserChipComponent#end_edit", e.target);
    }

    afterCommitEdit(anchorElement) {
        setTimeout(() => {
            this.stimulate("UserChipComponent#edited", anchorElement)
        }, 1600)
    }

}
