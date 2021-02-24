import ApplicationController from "../../javascript/controllers/application_controller"
import {Transition}          from "../../javascript/modules/transition-module";

export default class extends ApplicationController {
    static targets = [""];

    connect() {
        super.connect();
        this.setup();
    }


    async setup() {
        document.addEventListener("horizontal-event#open-event:before", (e) => {
            this.element.classList.add("hidden", "transform")
        }, false);
        document.addEventListener("horizontal-event#close-event:after", (e) => {
            this.element.classList.remove("hidden")
            Transition.to(this.element, {
                transition: () => this.element.classList.remove("opacity-0", "transform"),
                observed:   [],
                duration:   300
            }).then(el => {

            })
        }, false);
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

}
