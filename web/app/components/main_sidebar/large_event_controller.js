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

    close(event) {
        const animate = new Promise(resolve => {
            requestAnimationFrame((rafId) => {
                this.element.classList.add("opacity-0", "translate-x-32")
                setTimeout(() => {
                    resolve(rafId)
                }, 500)
            })
        })

        animate.then(result => {
            this.element.classList.add("hidden")
            this.element.classList.remove("opacity-0", "translate-x-32")
        })
    }

    _initSimpleScrollbar() {
        if (this.hasScrollContentTarget) {
            this.element.classList.remove("hidden")
            this.SimpleScrollbar.initEl(this.scrollContentTarget);
        }
    }
}
