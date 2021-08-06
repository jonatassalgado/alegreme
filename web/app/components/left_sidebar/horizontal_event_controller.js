import ApplicationController from "../../javascript/controllers/application_controller"
import {MobileDetector}      from "../../javascript/modules/mobile-detector-module";
import {Transition}          from "../../javascript/modules/transition-module";

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {

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

            const currentTarget = event.currentTarget
            this.beginEvent     = new Event("horizontal-event#open-event:before")
            this.endEvent       = new Event("horizontal-event#open-event:success");

            document.dispatchEvent(this.beginEvent)

            this.stimulate("Event#open", currentTarget, {resolveLate: true})
                .then(payload => {
                    document.dispatchEvent(this.endEvent)
                    window.dataLayer = window.dataLayer || [];
                    window.dataLayer.push({
                                              event:     "virtualPageview",
                                              pageUrl:   currentTarget.pathname,
                                              pageTitle: currentTarget.title
                                          });
                }).catch(payload => {

            })
        }
    }

    unlike(event) {
        const currentTarget = event.currentTarget

        Transition.to(this.element, {
            transition: () => this.element.classList.add("opacity-0"),
            observed:   ["opacity-0"],
            duration:   300
        }).then(value => {
            this.stimulate("LeftSidebar::Calendar#unlike", currentTarget)
        }, reason => {

        })
    }

    _linkEl(e) {
        return e.target.closest("[data-action~='click->left-sidebar--horizontal-event#openEvent']");
    }

    get mainSidebarLargeEventEl() {
        return document.querySelector("[data-controller~='main-sidebar--large-event']");
    }

}
