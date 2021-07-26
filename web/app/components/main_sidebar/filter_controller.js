import ApplicationController from "../../javascript/controllers/application_controller"
import {Transition}          from "../../javascript/modules/transition-module";

export default class extends ApplicationController {
    static targets = ["loadingIcon", "filters"];

    static values = {
        loading: Boolean
    }

    connect() {
        super.connect();
        this.setup();
    }


    async setup() {
        // document.addEventListener("horizontal-event#open-event:before", (e) => {
        //     this.element.classList.add("hidden", "transform")
        // }, false);
        // document.addEventListener("horizontal-event#close-event:after", (e) => {
        //     this.element.classList.remove("hidden")
        //     Transition.to(this.element, {
        //         transition: () => this.element.classList.remove("opacity-0", "transform"),
        //         observed:   [],
        //         duration:   300
        //     }).then(el => {
        //
        //     })
        // }, false);
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    beforeReflex(element) {
        this._startAnimate()
    }

    afterReflex(element) {
        this._endAnimate()
        document.dispatchEvent(new Event('feed#size-change:after'))
    }

    _startAnimate() {
        this.loadingValue = true
        document.dispatchEvent(new Event('filter#filtering:start'))
        Array.from(this.filtersTargets).forEach(filter => {
            filter.classList.add("opacity-50", "pointer-events-none")
        })
        setTimeout(() => {
            if (this.hasLoadingIconTarget && this.loadingValue) {
                this.loadingIconTarget.classList.remove("opacity-0")
                this.loadingIconTarget.classList.add("animate-spin")
            }
        }, 250)
    }

    _endAnimate() {
        if (this.hasFiltersTarget) {
            Array.from(this.filtersTargets).forEach(filter => {
                filter.classList.remove("opacity-50", "pointer-events-none")
            })
        }
        if (this.hasLoadingIconTarget) {
            this.loadingIconTarget.classList.add("opacity-0")
            setTimeout(() => {
                this.loadingIconTarget.classList.remove("animate-spin")
            }, 250)
        }
        this.loadingValue = false
        document.dispatchEvent(new Event('filter#filtering:end'))
    }

}
