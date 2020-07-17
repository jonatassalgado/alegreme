import ApplicationController from "./application_controller"

export default class MovieCollectionController extends ApplicationController {
    static targets = ["collection", "scrollContainer"];

    connect() {
        super.connect();
        this.setup()
    }

    beforeCache() {
        super.beforeCache();
        this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
        this.teardown();
    }

    disconnect() {
        super.disconnect();
    }

    setup() {
        this.scrollLeft = this.data.get("turbolinksPersistScroll");
    }

    teardown() {

    }

    set turbolinksPersistScroll(value) {
        this.data.set("turbolinksPersistScroll", value);
    }

    set scrollLeft(value) {
        if (value >= 0) {
            this.scrollContainerTarget.scrollLeft = value;
        }
    }

}
