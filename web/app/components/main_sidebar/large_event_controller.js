import ApplicationController from "../../javascript/controllers/application_controller"

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

    closeEvent(e) {

        this.element.innerHTML = null;
        // document.querySelector("#user-resources-list").classList.remove("hidden");
        this.stimulate('MainSidebar::LargeEventComponent#close', this.element)
            .then(payload => {

            })
            .catch(payload => {

            })
    }

    afterClose() {

    }

    _initSimpleScrollbar() {
        if (this.hasScrollContentTarget) {
            this.SimpleScrollbar.initEl(this.scrollContentTarget);
        }
    }
}
