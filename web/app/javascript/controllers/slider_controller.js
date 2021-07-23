import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ["left", "right", "scroller"];
    static values  = {
        distance: Number
    }

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
        let scrollLeft = this.scrollerTarget.scrollLeft;
        setTimeout(() => {
            requestAnimationFrame(() => {
                this.scrollerTarget.scrollTo({
                                                 left:     scrollLeft - this.distance,
                                                 behavior: this.behavior
                                             })
            })
            this.handleLeftRightButtons();
        }, 100)
    }

    right() {
        let scrollLeft = this.scrollerTarget.scrollLeft;
        setTimeout(() => {
            requestAnimationFrame(() => {
                this.scrollerTarget.scrollTo({
                                                 left:     scrollLeft + this.distance,
                                                 behavior: this.behavior
                                             })
            })
            this.handleLeftRightButtons();
        }, 100)
    }

    handleLeftRightButtons() {
        setTimeout(() => {
            let scrollLeft  = this.scrollerTarget.scrollLeft;
            let offsetWidth = this.scrollerTarget.offsetWidth;
            let scrollWidth = this.scrollerTarget.scrollWidth;

            if (scrollLeft === 0) {
                this.leftTarget.classList.add('hidden')
            } else {
                this.leftTarget.classList.remove('hidden')
            }
            if (scrollLeft + offsetWidth >= scrollWidth - 10) {
                this.rightTarget.classList.add('hidden')
            } else {
                this.rightTarget.classList.remove('hidden')
            }
        }, 350)
    }

    get distance() {
        return this.distanceValue || this.scrollerTarget.offsetWidth;
    }

    get behavior() {
        return this.data.get("behavior") || "smooth"
    }
}
