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

            this.stimulate("Event#open", event.currentTarget, {
                resolveLate: true
            }).then(payload => {
                // this._updateUrl(target);
                document.dispatchEvent(this.endEvent)
            }).catch(payload => {
            })
        }
    }

    like(event) {
        const currentTarget = event.currentTarget
        Velocity(this.element, {opacity: 0})
            .then(value => {
                document.dispatchEvent(new Event('swipable#suggestion-event:loading'))
                this.stimulate('Swipable#like', currentTarget)
                    .then(value => {
                        document.dispatchEvent(new Event('swipable#suggestion-event:loaded'))
                        this._updateCalendar()
                    })
                    .catch(reason => {

                    })
            }, reason => {

            })
    }

    dislike(event) {
        const currentTarget = event.currentTarget
        Velocity(this.element, {opacity: 0})
            .then(value => {
                document.dispatchEvent(new Event('swipable#suggestion-event:loading'))
                this.stimulate('Swipable#dislike', currentTarget)
                    .then(value => {
                        document.dispatchEvent(new Event('swipable#suggestion-event:loaded'))
                    })
                    .catch(reason => {

                    })
            }, reason => {

            })
    }

    _updateCalendar() {
        const calendar = document.querySelector('#calendar')
        if (calendar) {
            this.stimulate('LeftSidebar::Calendar#update', calendar, {resolveLate: true})
        }
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


    }

    get openInSidebar() {
        return JSON.parse(this.data.get('openInSidebar'))
    }


}
