import ApplicationController from "../../javascript/controllers/application_controller"
import {MobileDetector}      from "../../javascript/modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {
        const {MobileDetector} = await import("../../javascript/modules/mobile-detector-module");
        this.beginEvent        = new Event("horizontal-event#open-event:before")
        this.endEvent          = new Event("horizontal-event#open-event:success");
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
            const target = this._linkEl(event);

            this._userResourceListEl().classList.add("hidden");
            document.dispatchEvent(this.beginEvent)

            this.stimulate("MainSidebar::LargeEventComponent#open", this._mainSidebarLargeEventEl(), {
                event_id: target.dataset.eventId
            }).then(payload => {
                // this._updateUrl(target);
                document.dispatchEvent(this.endEvent)
            }).catch(payload => {
                this._userResourceListEl().classList.remove("hidden");
            })
        }
    }

    _linkEl(e) {
        return e.target.closest("[data-action~='click->main-sidebar--horizontal-event#openEvent']");
    }

    _updateUrl(target) {
        window.history.replaceState({}, "", `${target.href.replace(target.origin, "")}`);
    }

    _userResourceListEl() {
        return document.querySelector("#user-resources-list");
    }

    _mainSidebarLargeEventEl() {
        return document.querySelector("[data-controller~='main-sidebar--large-event']");
    }

    get openInSidebar() {
        return JSON.parse(this.data.get('openInSidebar'))
    }

}
