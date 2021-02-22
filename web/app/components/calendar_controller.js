import ApplicationController from "../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = ['loadingIcon', 'table', 'list'];

    initialize() {
        const self = this;
    }

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

    beforePrevMonth() {
        this._loadingAnimate()
    }

    beforeNextMonth() {
        this._loadingAnimate()
    }

    beforeInDay(anchorElement) {
        this._loadingAnimate()
        const dateGroup = document.querySelector(`#main-sidebar--group-${anchorElement.dataset.day}`);
        if (dateGroup) dateGroup.scrollIntoView({
                                                    block:    'start',
                                                    behavior: 'smooth'
                                                })
    }

    inDay(event) {
        const target = event.target.closest('td');

        if (target && target.classList.contains('filter')) {
            this.stimulate('Calendar#clear_filter', target, {resolveLate: true})
                .then(payload => {

                })
                .catch(payload => {

                })
        } else {
            if (target) {
                this.stimulate('Calendar#in_day', target, {resolveLate: true})
            }
        }
    }

    beforeClearFilter(anchorElement) {
        this._loadingAnimate()
    }

    _loadingAnimate() {
        this.loadingIconTarget.classList.remove("opacity-0")
        this.loadingIconTarget.classList.add("animate-spin")
        this.tableTarget.classList.add("animate-pulse")
        this.listTarget.classList.add("animate-pulse")
    }

}
