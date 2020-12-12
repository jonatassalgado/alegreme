import ApplicationController from "../../javascript/controllers/application_controller"
import {debounce}            from "../../javascript/utilities";

export default class extends ApplicationController {
    static targets = ['calendar'];

    initialize() {
        const self = this;

        [
            'hero--swipable:liked-or-disliked',
            'main-sidebar--horizontal-event:liked-or-disliked'
        ].forEach(e => {
            document.addEventListener(e, debounce(self.update.bind(self), 750))
        })
    }

    connect() {
        super.connect();
        this.setup();
    }

    setup() {

    }

    teardown() {
        [
            'hero--swipable:liked-or-disliked',
            'main-sidebar--horizontal-event:liked-or-disliked'
        ].forEach(e => {
            document.removeEventListener(e, debounce(this.update.bind(this), 750))
        })
    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    update() {
        this.stimulate('LeftSidebar::MyAgendaComponent#update', this.element)
            .then(payload => {

            }).catch(payload => {

        })
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

        if (target.classList.contains('start-date')) {
            this.stimulate('LeftSidebar::MyAgendaComponent#clear_filter', target)
                .then(payload => {

                })
                .catch(payload => {

                })
        } else {
            this.stimulate('LeftSidebar::MyAgendaComponent#in_day', target)
        }
    }

    afterClearFilter(anchorElement) {
        // this._unselectDays(this.calendarTarget);
    }

    _initSimpleScrollbar() {
        this.SimpleScrollbar.initEl(this.scrollContentTarget);
    }
}
