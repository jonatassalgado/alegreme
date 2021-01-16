import ApplicationController from "../../javascript/controllers/application_controller"
import {MobileDetector}      from "../../javascript/modules/mobile-detector-module";
import Velocity              from "velocity-animate";

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this.beginEvent = new Event("horizontal-event#open-event:before")
        this.endEvent   = new Event("horizontal-event#open-event:success");
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
        if (!MobileDetector.mobile() && this.openInSidebar) {
            event.preventDefault()
            event.stopPropagation()

            document.dispatchEvent(this.beginEvent)

            this.stimulate("Event#open", event.target, {
                resolveLate: true
            }).then(payload => {
                // this._updateUrl(target);
                document.dispatchEvent(this.endEvent)
            }).catch(payload => {
            })
        }
    }

    beforeLike(anchorElement) {
        this._animateHide(this.element)
    }

    beforeDislike(anchorElement) {
        this._animateHide(this.element)
    }

    like(event) {
        this.stimulate('Swipable#like', event.currentTarget)
            .then(value => {
                this._updateCalendar()
            })
            .catch(reason => {

            })
    }

    dislike(event) {
        this.stimulate('Swipable#dislike', event.currentTarget)
            .then(value => {
                this._updateCalendar()
            })
            .catch(reason => {

            })
    }

    _updateCalendar() {
        const calendar = document.querySelector('#calendar')
        this.stimulate('Calendar#update', calendar, {resolveLate: true})
    }

    _linkEl(e) {
        return e.target.closest("[data-action~='click->hero--horizontal-event#openEvent']");
    }

    _updateUrl(target) {
        window.history.replaceState({}, "", `${target.href.replace(target.origin, "")}`);
    }

    _mainSidebarLargeEventEl() {
        return document.querySelector("[data-controller~='main-sidebar--large-event']");
    }

    _animateHide(element) {
        // element.dataset.reflexPermanent = ''

        Velocity(element, {opacity: 0})
            .then(value => {
                element.classList.add('hidden')
            }, reason => {

            })
    }

    get openInSidebar() {
        return JSON.parse(this.data.get('openInSidebar'))
    }


}
