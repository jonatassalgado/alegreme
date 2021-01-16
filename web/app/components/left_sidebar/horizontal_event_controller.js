import ApplicationController from "../../javascript/controllers/application_controller"
import {MobileDetector}      from "../../javascript/modules/mobile-detector-module";

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

    openEvent(event) {
        if (!MobileDetector.mobile()) {
            event.preventDefault()
            event.stopPropagation()

            const target    = this._linkEl(event);
            this.beginEvent = new Event("horizontal-event#open-event:before")
            this.endEvent   = new Event("horizontal-event#open-event:success");

            document.dispatchEvent(this.beginEvent)

            this.stimulate("Event#open", event.target, {resolveLate: true}).then(payload => {
                document.dispatchEvent(this.endEvent)
            }).catch(payload => {

            })
        }
    }

    beforeUnlike(anchorElement) {
        this._animateHide(this.element)
    }

    _linkEl(e) {
        return e.target.closest("[data-action~='click->left-sidebar--horizontal-event#openEvent']");
    }

    _animateHide(element) {
        element.dataset.reflexPermanent = ''

        Velocity(element, {opacity: 0})
            .then(value => {
                setTimeout(() => {
                    element.classList.add('hidden')
                }, 250)
            }, reason => {

            })
    }

    get mainSidebarLargeEventEl() {
        return document.querySelector("[data-controller~='main-sidebar--large-event']");
    }

}
