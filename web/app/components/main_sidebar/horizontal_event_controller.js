import ApplicationController from "../../javascript/controllers/application_controller"
import {MobileDetector}      from "../../javascript/modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {

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
            const target    = this._linkEl(event);
            this.beginEvent = new Event("horizontal-event#open-event:before")
            this.endEvent   = new Event("horizontal-event#open-event:success");

            document.dispatchEvent(this.beginEvent)

            this.stimulate("Event#open",
                           event.target,
                           {resolveLate: true}
            ).then(payload => {
                document.dispatchEvent(this.endEvent)
                window.dataLayer = window.dataLayer || [];
                window.dataLayer.push({
                                          event:     "virtualPageview",
                                          pageUrl:   event.target.pathname,
                                          pageTitle: event.target.innerText
                                      });
            }).catch(payload => {

            })
        }
    }

    like(event) {
        this.stimulate('Event#like', event.currentTarget)
            .then(value => {
                this._updateCalendar()
            })
            .catch(reason => {

            })
    }

    dislike(event) {
        this.stimulate('Event#dislike', event.currentTarget)
            .then(value => {
                this._updateCalendar()
            })
            .catch(reason => {

            })
    }

    _updateCalendar() {
        const calendar = document.querySelector('#calendar')
        if (calendar) {
            this.stimulate('LeftSidebar::Calendar#update', calendar, {resolveLate: true})
        }
    }

    _linkEl(e) {
        return e.target.closest("[data-action~='click->main-sidebar--horizontal-event#openEvent']");
    }

    _updateUrl(target) {
        window.history.replaceState({}, "", `${target.href.replace(target.origin, "")}`);
    }

    get openInSidebar() {
        return JSON.parse(this.data.get('openInSidebar'))
    }

}
