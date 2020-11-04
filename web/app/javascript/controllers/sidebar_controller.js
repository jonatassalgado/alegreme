import ApplicationController from "./application_controller"
import StickySidebar      from "sticky-sidebar";


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

    setup() {
        this.sidebar = new StickySidebar(`#${this.element.parentElement.id}`, {
            containerSelector:    `#${this.element.parentElement.parentElement.id}`,
            innerWrapperSelector: `#${this.element.id}`,
            topSpacing:           50,
            bottomSpacing:        50
        });
    }

    teardown() {
        this.sidebar.destroy()
    }

}
