import ApplicationController from "../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [''];

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

    beforeInDay(anchorElement) {
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

    afterClearFilter(anchorElement) {
        // this._unselectDays(this.calendarTarget);
    }

}
