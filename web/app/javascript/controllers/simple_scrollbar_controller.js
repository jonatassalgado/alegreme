import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    async setup() {
        await import("simple-scrollbar/simple-scrollbar.css")
        this.SimpleScrollbar = await import("simple-scrollbar")
        if (!this.element.classList.contains("ss-container")) {
            this.SimpleScrollbar.initEl(this.element);
        }
    }

    teardown() {

    }

}
