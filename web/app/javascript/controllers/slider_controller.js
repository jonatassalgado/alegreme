import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ['left', 'right', 'scroller', 'item'];
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

    select(event) {
        if (this.hasItemTarget) {
            this.itemTargets.forEach((item) => {
                item.classList.remove('border-2', 'border-brand-600', 'rounded-lg', 'scale-105');
                if (event.detail.url === item.querySelector('a').href) {
                    item.classList.add('border-2', 'border-brand-600', 'rounded-lg', 'scale-105');
                }
            })
        }
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
