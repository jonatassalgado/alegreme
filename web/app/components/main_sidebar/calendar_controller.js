import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = ['calendar'];

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

    inDay(event) {
        const target = event.target.closest('td');

        if (target.classList.contains('start-date')) {
            this.stimulate('MainSidebar::CalendarComponent#clear_filter', target)
                .then(payload => {

                })
                .catch(payload => {

                })
        } else {
            this.stimulate('MainSidebar::CalendarComponent#in_day', target)
        }
    }

}
