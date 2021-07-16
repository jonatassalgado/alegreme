import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ["scroller"];
    static values = {
        turboPersistScroll: Number
    }

    connect() {
        super.connect();
        this.setup()
    }

    beforeCache() {
        super.beforeCache();
        this.turboPersistScrollValue = this.scrollerTarget.scrollLeft;
        this.teardown();
    }

    disconnect() {
        super.disconnect();
    }

    setup() {
        if(this.hasScrollerTarget) {
            this.scrollerTarget.scrollLeft = this.turboPersistScrollValue;
        }
    }

    teardown() {

    }

}
