import ApplicationController from "../../javascript/controllers/application_controller"
import {Transition}          from "../../javascript/modules/transition-module";

export default class extends ApplicationController {
    static targets = ["scrollContent"];

    connect() {
        super.connect();
        this.setup();
    }


    async setup() {
        this.SimpleScrollbar = await import("simple-scrollbar")
        await import("simple-scrollbar/simple-scrollbar.css")

        this.element.addEventListener("cable-ready:before-morph", event => {
            this.element.innerHTML = null;
        })

        this.element.addEventListener("cable-ready:after-morph", event => {
            this._initSimpleScrollbar()
        })
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    close(event) {
        Transition.to(this.element, {
            transition: () => this.element.classList.add("opacity-0", "translate-x-32"),
            observed:   ["opacity-0", "translate-x-32"],
            resetState: true,
            duration:   300
        }).then(el => {
            this.element.classList.add("hidden")
            document.dispatchEvent(new Event("horizontal-event#close-event:after"))
        })
    }

    _initSimpleScrollbar() {
        if (this.hasScrollContentTarget) {
            this.element.classList.remove("hidden")
            this.SimpleScrollbar.initEl(this.scrollContentTarget);
        }
    }
}
