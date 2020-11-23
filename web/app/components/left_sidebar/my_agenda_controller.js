import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = ['calendar', 'scrollContent'];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {
        this.SimpleScrollbar = await import("simple-scrollbar")
        await import("simple-scrollbar/simple-scrollbar.css")
        this._initSimpleScrollbar()

        this.element.addEventListener("cable-ready:before-morph", event => {
            this.element.innerHTML = null;
        })

        this.element.addEventListener("cable-ready:after-morph", event => {
            this._initSimpleScrollbar()
        })
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
        if (dateGroup) dateGroup.scrollIntoView({block: 'start', behavior: 'smooth'})
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

    afterInDay(anchorElement) {
        // setTimeout(() => {
        //     let unselectedDays = this._unselectDays(this.calendarTarget);
        //
        //     Promise.all(unselectedDays).then(days => {
        //         anchorElement.classList.add('start-date');
        //         anchorElement.querySelector("[data-indicator]").classList.remove('bg-green-500');
        //         anchorElement.querySelector("[data-indicator]").classList.add('bg-white');
        //     })
        // }, 500)
    }

    afterClearFilter(anchorElement) {
        // this._unselectDays(this.calendarTarget);
    }

    _unselectDays(calendar) {
        return Array.from(calendar.querySelectorAll('td.start-date')).map(el => {
            return new Promise((resolve, reject) => {
                el.classList.remove('start-date')
                el.querySelector("[data-indicator]").classList.remove('bg-white')
                el.querySelector("[data-indicator]").classList.add('bg-green-500')
                if (!el.classList.contains('start-date')) resolve(el);
            })
        });
    }

    _initSimpleScrollbar() {
        this.SimpleScrollbar.initEl(this.scrollContentTarget);
    }
}
