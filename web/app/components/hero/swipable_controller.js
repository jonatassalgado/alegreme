import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    async initialize() {
        const FlippingWeb = await import('flipping/lib/adapters/web')
        this.flipping     = new FlippingWeb.default();

        this.element.addEventListener("cable-ready:before-morph", event => {
            this.flipping.read()
        })

        this.element.addEventListener("cable-ready:after-morph", event => {
            this.flipping.flip()
        })
    }

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        // this._setMinHeigth();
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    update(event) {
        this.stimulate('Hero::SwipableComponent#update')
    }

    beforeHideSwipable() {
        this._hideSwipable()
    }

    _setMinHeigth() {
        setTimeout(() => {
            if (this.element.offsetHeight > 0) {
                this.element.style.minHeight = `${this.element.offsetHeight}px`
            }
        }, 250)
    }

    _hideSwipable() {
        this.element.style.display = "none"
    }

}
