import ApplicationController from "./application_controller"

export default class MovieCollectionController extends ApplicationController {
    static targets = ["collection", "scrollContainer"];

    connect() {
        super.connect();
        this.setup()
    }

    beforeCache() {
        super.beforeCache();
        this.turboPersistScroll = this.scrollContainerTarget.scrollLeft;
        this.teardown();
    }

    disconnect() {
        super.disconnect();
    }

    setup() {
        this.scrollLeft = this.data.get("turboPersistScroll");
    }

    teardown() {

    }

    set turboPersistScroll(value) {
        this.data.set("turboPersistScroll", value);
    }

    set scrollLeft(value) {
        if (value >= 0) {
            this.scrollContainerTarget.scrollLeft = value;
        }
    }

}
