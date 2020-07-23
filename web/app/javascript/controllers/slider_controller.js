import ApplicationController from "./application_controller"

export default class SliderController extends ApplicationController {
    static targets = ["left", "right", "scroller"];

    connect() {
        super.connect();


    }

    beforeCache() {
        super.beforeCache();
        // this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    teardown() {

    }

    left() {
        requestAnimationFrame(() => {
            this.scrollerTarget.scrollTo({
                                             left:     this.scrollerTarget.scrollLeft - this.distance,
                                             behavior: this.behavior
                                         })
        })
    }

    right() {
        requestAnimationFrame(() => {
            this.scrollerTarget.scrollTo({
                                             left:     this.scrollerTarget.scrollLeft + this.distance,
                                             behavior: this.behavior
                                         })
        })
    }

    get distance() {
        return this.data.get("distance") || this.scrollerTarget.offsetWidth;
    }

    get behavior() {
        return this.data.get("behavior") || "smooth"
    }
}
