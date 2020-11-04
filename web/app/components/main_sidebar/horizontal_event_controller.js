import ApplicationController from "../../javascript/controllers/application_controller"

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
        event.preventDefault();
        const target = this._linkEl(event);

        this._userResourceListEl().classList.add("hidden");
        document.dispatchEvent(this.beginEvent)

        this.stimulate("MainSidebar::LargeEventComponent#open", this._mainSidebarLargeEventEl(), {
            event_id: target.dataset.eventId
        }).then(payload => {
            this._updateUrl(target);
            document.dispatchEvent(this.endEvent)
        }).catch(payload => {
            this._userResourceListEl().classList.remove("hidden");
        })
    }

    afterLike(anchorElement) {
        const myAgenda = document.querySelector("#my-agenda");

        this.stimulate("LeftSidebar::MyAgendaComponent#update", myAgenda).then(payload => {

        }).catch(payload => {

        })
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

}
