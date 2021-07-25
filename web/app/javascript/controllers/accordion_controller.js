import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ["hidden", "visible"];
    static values  = {
        open: Boolean
    }

    connect() {
        super.connect();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {

    }

    teardown() {

    }

    toggle() {
        if (this.openValue) {
            this.hiddenTargets.forEach((el) => {
                el.classList.add('hidden')
            })
            this.visibleTargets.forEach((el) => {
                el.classList.remove('hidden')
            })
        } else {
            this.hiddenTargets.forEach((el) => {
                el.classList.remove('hidden')
            })
            this.visibleTargets.forEach((el) => {
                el.classList.add('hidden')
            })
        }

        this.openValue = !this.openValue
    }

}
