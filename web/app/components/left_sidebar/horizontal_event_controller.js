import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {
        const Velocity = await import('velocity-animate');
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    beforeUnlike(anchorElement) {
        this._animateHide(this.element)
    }

    _animateHide(element) {
        Velocity(element, {opacity: 0})
            .then(value => {
                setTimeout(() => {
                    element.classList.add('hidden')
                }, 250)
            }, reason => {

            })
    }

}
