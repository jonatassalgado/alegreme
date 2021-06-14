import ApplicationController from "../../javascript/controllers/application_controller"
import {MobileDetector}      from "../../javascript/modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = [];
    static values  = {
        open:          Boolean,
        openInSidebar: Boolean
    }

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        this.initialUrl = window.location.href
        document.addEventListener('horizontal-event#close-event:after', () => {
            if (!MobileDetector.mobile() && this.openInSidebarValue && this.openValue) {
                this.openValue = false
                this._cleanUrl()
            }
        }, false)
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
        if (!MobileDetector.mobile() && this.openInSidebarValue) {
            event.preventDefault()
            event.stopPropagation()
            this.beginEvent = new Event("horizontal-event#open-event:before")
            this.endEvent   = new Event("horizontal-event#open-event:success");

            document.dispatchEvent(this.beginEvent)

            this.stimulate("Event#open",
                           event.target,
                           {resolveLate: true}
            ).then(payload => {
                this.openValue = true
                this._updateUrl(this._linkEl(event))
                document.dispatchEvent(this.endEvent)
                window.dataLayer = window.dataLayer || [];
                window.dataLayer.push({
                                          event:     "virtualPageview",
                                          pageUrl:   event.target.pathname,
                                          pageTitle: event.target.innerText
                                      });
            }).catch(payload => {

            })
        } else if (!MobileDetector.mobile() && !this.openInSidebarValue) {
            event.preventDefault()
            event.stopPropagation()
            this._cleanUrl()
            Turbo.visit(this._linkEl(event).href)
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
        return e.target.closest("a");
    }

    _updateUrl(target) {
        window.history.pushState({
                                     turbo: true,
                                     url:   target.href.replace(target.origin, "")
                                 }, '', target.href.replace(target.origin, ""))
        // window.history.replaceState({}, "", target.href.replace(target.origin, ""));
    }

    _cleanUrl() {
        window.history.replaceState({
                                        turbo: true,
                                        url:   this.initialUrl
                                    }, '', this.initialUrl)
    }


}
